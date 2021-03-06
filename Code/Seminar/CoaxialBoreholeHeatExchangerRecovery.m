classdef CoaxialBoreholeHeatExchangerRecovery
    
    properties (Constant)
        MESH_SIZE_EXTREMELY_FINE = 1
        MESH_SIZE_EXTRA_FINE = 2
        MESH_SIZE_FINER = 3
        MESH_SIZE_FINE = 4
        MESH_SIZE_NORMAL = 5
        MESH_SIZE_COARSE = 6
        MESH_SIZE_COARSER = 7
        MESH_SIZE_EXTRA_COARSE = 8
        MESH_SIZE_EXTREMELY_COARSE = 9
    end
    
    properties (Constant)
        INNER_CAP_MAX_ELEMENT_SIZE = 0.015 % 0.015
        INNER_CAP_ELEMENT_SIZE = CoaxialBoreholeHeatExchangerRecovery.MESH_SIZE_EXTREMELY_FINE
        OUTER_CAP_MAX_ELEMENT_GROWTH_RATE = 1.2 % 1.2
        OUTER_CAP_ELEMENT_SIZE = CoaxialBoreholeHeatExchangerRecovery.MESH_SIZE_EXTREMELY_FINE
        BOREHOLE_STRUCTURE_NUM_ELEMENTS = 100 % 100
        BOREHOLE_STRUCTURE_ELEMENT_RATIO = 5 % 5
        CYLINDER_ELEMENT_SIZE = CoaxialBoreholeHeatExchangerRecovery.MESH_SIZE_FINER
    end
    
    properties
        id
        boreholeCollar, boreholeFooter, boreholeDiameter, flowRate, heatCarrierFluid, coaxialPipe, cutPlanes, bufferRadius
        boreholeRadius, boreholeLength, boreholeAxis, thermalConductivityTensor
        outerFluidVelocity, innerFluidVelocity
    end
    
    methods
        
        function obj = CoaxialBoreholeHeatExchangerRecovery(boreholeCollar, boreholeFooter, boreholeDiameter, coaxialPipe, flowRate, heatCarrierFluid, varargin)
            
            persistent id
            
            if boreholeDiameter <= 0
                error('Borehole must have positive diameter.');
            end
            
            if coaxialPipe.outerWallDiameter >= boreholeDiameter
                error('Borehole diameter must be larger than outer pipe diameter.');
            end
            
            if flowRate <= 0
                error('Flow rate must be positive.');
            end
            
            if isempty(id)
                id = 1;
            else
                id = id + 1;
            end
            
            obj.id = id;
            
            obj.boreholeCollar = boreholeCollar;
            obj.boreholeFooter = boreholeFooter;
            obj.boreholeDiameter = boreholeDiameter;
            obj.boreholeLength = sqrt((boreholeFooter(1)-boreholeCollar(1))^2+(boreholeFooter(2)-boreholeCollar(2))^2+(boreholeFooter(3)-boreholeCollar(3))^2);
            obj.flowRate = flowRate;
            obj.heatCarrierFluid = heatCarrierFluid;
            obj.coaxialPipe = coaxialPipe;
            
            obj.boreholeRadius = 0.5 * boreholeDiameter;
            
            % Handles variable arguments in.
            
            obj.cutPlanes = {};
            obj.bufferRadius = 1.0;
            
            for i = 1:2:numel(varargin)
                if strcmpi(varargin{i}, 'cutplanes')
                    obj.cutPlanes = varargin{i+1};
                elseif strcmpi(varargin{i}, 'bufferradius')
                    obj.bufferRadius = varargin{i+1};
                else
                    error('Invalid named argument: "%s".', varargin{i});
                end
            end
            
            if obj.bufferRadius <= obj.boreholeRadius
                error('Buffer radius must be larger than borehole radius.');
            end
            
            % Calculates borehole axis.
            
            obj.boreholeAxis = [boreholeFooter(1)-boreholeCollar(1), boreholeFooter(2)-boreholeCollar(2), boreholeFooter(3)-boreholeCollar(3)] / obj.boreholeLength;
            
            theta = acos(obj.boreholeAxis(3));
            phi = atan2(obj.boreholeAxis(2), obj.boreholeAxis(1));
            
            % Constructs rotation matrix.
            
            boreholeTilt = 90 - 180 * theta / pi;
            boreholeAzimuth = 180 * phi / pi;
            
            if boreholeAzimuth < 0
                boreholeAzimuth = boreholeAzimuth + 360;
            end
            
            if boreholeTilt > 0
                error('Borehole must be downwards directed.');
            end
            
            theta = pi * boreholeTilt / 180;
            phi = pi * boreholeAzimuth / 180;
            
            rotationMatrix = [cos(phi)*cos(theta) -sin(phi) -sin(theta)*cos(phi); sin(phi)*cos(theta) cos(phi) -sin(phi)*sin(theta); sin(theta) 0 cos(theta)];
            
            % Constructs thermal conductivity tensor.
            
            thermalConductivityTensor = [[heatCarrierFluid.thermalConductivity, 0, 0]; [0, 1000, 0]; [0, 0, 1000]];
            
            obj.thermalConductivityTensor = rotationMatrix * thermalConductivityTensor * pinv(rotationMatrix);
            
            % Calculates fluid velocities.
            
            outerFluidArea = pi * obj.boreholeRadius^2 - pi * coaxialPipe.outerWallRadius^2;
            innerFluidArea = pi * coaxialPipe.innerWallRadius^2;
            
            obj.outerFluidVelocity = obj.flowRate / outerFluidArea * obj.boreholeAxis;
            obj.innerFluidVelocity = obj.flowRate / innerFluidArea * -obj.boreholeAxis;
            
            fprintf(1, 'CoaxialBoreholeHeatExchangerRecovery(id=%d tilt=%.1f azimuth=%.1f length=%.1f Q=%.3f)\n', obj.id, boreholeTilt, boreholeAzimuth, obj.boreholeLength, obj.flowRate*1000);
            
        end
        
        function plot(obj)
            plot3(obj.boreholeCollar(1), obj.boreholeCollar(2), obj.boreholeCollar(3), 'r.')
            plot3(obj.boreholeFooter(1), obj.boreholeFooter(2), obj.boreholeFooter(3), 'ro')
            plot3([obj.boreholeCollar(1), obj.boreholeFooter(1)], [obj.boreholeCollar(2), obj.boreholeFooter(2)], [obj.boreholeCollar(3), obj.boreholeFooter(3)], 'r-')
        end
        
        function tags = createWorkPlaneStructure(obj, workPlane, radiuses)
            
            circleTags = cell(1, length(radiuses));
            
            for i = 1:numel(radiuses)
                circleTags{i} = sprintf('circle%d', i);
                circle = workPlane.geom.create(circleTags{i}, 'Circle');
                circle.label(sprintf('Circle %d', i));
                circle.set('r', radiuses(i)');
            end
            
            polygonTags = cell(1, length(obj.cutPlanes));
            
            for i = 1:numel(obj.cutPlanes)
                polygonTags{i} = obj.cutPlanes{i}.createCutStructure(workPlane, max(radiuses));
            end
            
            if ~isempty(obj.cutPlanes)
                difference = workPlane.geom.create('difference', 'Difference');
                difference.selection('input').set(circleTags);
                difference.selection('input2').set(polygonTags);
            end
            
            tags = cat(2, circleTags, polygonTags);
            
        end
        
        function tags = createGeometry(obj, geometry)
            
            % Creates the borehole heat exchanger structure.
            
            tags{1} = sprintf('work_plane_cbhe_structure%d', obj.id);
            
            workPlane = geometry.create(tags{1}, 'WorkPlane');
            workPlane.label(sprintf('Work Plane for CBHE Structure %d', obj.id));
            
            workPlane.set('planetype', 'normalvector');
            workPlane.set('normalcoord', to_cell_array(obj.boreholeCollar));
            workPlane.set('normalvector', to_cell_array(obj.boreholeAxis));
            
            workPlane.set('unite', true);
            
            obj.createWorkPlaneStructure(workPlane, [obj.bufferRadius, obj.boreholeRadius, obj.coaxialPipe.outerWallRadius, obj.coaxialPipe.innerWallRadius]);
            
            tags{2} = sprintf('extrusion_cbhe_structure%d', obj.id);
            
            extrusion = geometry.create(tags{2}, 'Extrude');
            extrusion.label(sprintf('Extrusion for CBHE Structure Work Plane %d', obj.id));
            
            extrusion.setIndex('distance', obj.boreholeLength, 0);
            extrusion.selection('input').set(tags{1});
            
            % Creates the upper cylinder above the borehole heat exchanger.
            
            bufferCollar = obj.boreholeCollar - obj.bufferRadius * obj.boreholeAxis;
            
            tags{3} = sprintf('work_plane_upper_cylinder%d', obj.id);
            
            workPlane = geometry.create(tags{3}, 'WorkPlane');
            workPlane.label(sprintf('Work Plane for Upper Cylinder %d', obj.id));
            
            workPlane.set('planetype', 'normalvector');
            workPlane.set('normalcoord', to_cell_array(bufferCollar));
            workPlane.set('normalvector', to_cell_array(obj.boreholeAxis));
            
            workPlane.set('unite', true);
            
            obj.createWorkPlaneStructure(workPlane, obj.bufferRadius);
            
            tags{4} = sprintf('extrusion_upper_cylinder%d', obj.id);
            
            extrusion = geometry.create(tags{4}, 'Extrude');
            extrusion.label(sprintf('Extrusion for Upper Cylinder Work Plane %d', obj.id));
            
            extrusion.setIndex('distance', obj.bufferRadius, 0);
            extrusion.selection('input').set(tags{3});
            
            % Creates the lower cylinder below the borehole heat exchanger.
            
            tags{5} = sprintf('work_plane_lower_cylinder%d', obj.id);
            
            workPlane = geometry.create(tags{5}, 'WorkPlane');
            workPlane.label(sprintf('Work Plane for Lower Cylinder %d', obj.id));
            
            workPlane.set('planetype', 'normalvector');
            workPlane.set('normalcoord', to_cell_array(obj.boreholeFooter));
            workPlane.set('normalvector', to_cell_array(obj.boreholeAxis));
            
            workPlane.set('unite', true);
            
            obj.createWorkPlaneStructure(workPlane, obj.bufferRadius);
            
            tags{6} = sprintf('extrusion_lower_cylinder%d', obj.id);
            
            extrusion = geometry.create(tags{6}, 'Extrude');
            extrusion.label(sprintf('Extrusion for Lower Cylinder Work Plane %d', obj.id));
            
            extrusion.setIndex('distance', obj.bufferRadius, 0);
            extrusion.selection('input').set(tags{5});
            
        end
        
        function tags = createSelections(obj, geometry)
            
            % Creates a selection containing the buffer zone domain.
            
            tags{1} = sprintf('buffer_zone_selection%d', obj.id);
            
            bufferZoneSelection = geometry.create(tags{1}, 'CylinderSelection');
            bufferZoneSelection.label(sprintf('Buffer Zone Selection %d', obj.id));
            
            bufferZoneSelection.set('r', obj.bufferRadius+0.001);
            bufferZoneSelection.set('rin', obj.boreholeRadius-0.001);
            bufferZoneSelection.set('top', obj.boreholeLength+0.001);
            bufferZoneSelection.set('bottom', -0.001);
            bufferZoneSelection.set('pos', to_cell_array(obj.boreholeCollar));
            bufferZoneSelection.set('axis', to_cell_array(obj.boreholeAxis));
            bufferZoneSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the outer fluid domain.
            
            tags{2} = sprintf('outer_fluid_selection%d', obj.id);
            
            outerFluidSelection = geometry.create(tags{2}, 'CylinderSelection');
            outerFluidSelection.label(sprintf('Outer Fluid Selection %d', obj.id));
            
            outerFluidSelection.set('r', obj.boreholeRadius+0.001);
            outerFluidSelection.set('rin', obj.coaxialPipe.outerWallRadius-0.001);
            outerFluidSelection.set('top', obj.boreholeLength+0.001);
            outerFluidSelection.set('bottom', -0.001);
            outerFluidSelection.set('pos', to_cell_array(obj.boreholeCollar));
            outerFluidSelection.set('axis', to_cell_array(obj.boreholeAxis));
            outerFluidSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the pipe wall domain.
            
            tags{3} = sprintf('pipe_wall_selection%d', obj.id);
            
            pipeWallSelection = geometry.create(tags{3}, 'CylinderSelection');
            pipeWallSelection.label(sprintf('Pipe Wall Selection %d', obj.id));
            
            pipeWallSelection.set('r', obj.coaxialPipe.outerWallRadius+0.001);
            %pipeWallSelection.set('rin', obj.inner_pipe_radius-0.001);
            pipeWallSelection.set('rin', +0.001); %%% HACK %%%
            pipeWallSelection.set('top', obj.boreholeLength+0.001);
            pipeWallSelection.set('bottom', -0.001);
            pipeWallSelection.set('pos', to_cell_array(obj.boreholeCollar));
            pipeWallSelection.set('axis', to_cell_array(obj.boreholeAxis));
            %pipeWallSelection.set('condition', 'allvertices');
            pipeWallSelection.set('condition', 'inside'); %%% HACK %%%
            
            % Creates a selection containing the inner fluid domain.
            
            tags{4} = sprintf('inner_fluid_selection%d', obj.id);
            
            innerFluidSelection = geometry.create(tags{4}, 'CylinderSelection');
            innerFluidSelection.label(sprintf('Inner Fluid Selection %d', obj.id));
            
            innerFluidSelection.set('r', obj.coaxialPipe.innerWallRadius+0.001);
            innerFluidSelection.set('rin', '0');
            innerFluidSelection.set('top', obj.boreholeLength+0.001);
            innerFluidSelection.set('bottom', -0.001);
            innerFluidSelection.set('pos', to_cell_array(obj.boreholeCollar));
            innerFluidSelection.set('axis', to_cell_array(obj.boreholeAxis));
            innerFluidSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the parts of the borehole structure.
            
            tags{5} = sprintf('borehole_structure_selection%d', obj.id);
            
            boreholeStructureSelection = geometry.create(tags{5}, 'UnionSelection');
            boreholeStructureSelection.label(sprintf('Borehole Structure Selection %d', obj.id));
            boreholeStructureSelection.set('input', {tags{1}, tags{2}, tags{3}, tags{4}});
            
            % Creates a selection containing the borehole wall boundary.
            
            tags{6} = sprintf('borehole_wall_selection%d', obj.id);
            
            boreholeWallSelection = geometry.create(tags{6}, 'CylinderSelection');
            boreholeWallSelection.label(sprintf('Borehole Wall Selection %d', obj.id));
            
            boreholeWallSelection.set('entitydim', 2);
            boreholeWallSelection.set('r', obj.boreholeRadius+0.001);
            boreholeWallSelection.set('rin', obj.boreholeRadius-0.001);
            boreholeWallSelection.set('top', obj.boreholeLength+0.001);
            boreholeWallSelection.set('bottom', -0.001);
            boreholeWallSelection.set('pos', to_cell_array(obj.boreholeCollar));
            boreholeWallSelection.set('axis', to_cell_array(obj.boreholeAxis));
            boreholeWallSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the upper cylinder domain.
            
            bufferCollar = obj.boreholeCollar - obj.bufferRadius * obj.boreholeAxis;
            
            tags{7} = sprintf('upper_cylinder_selection%d', obj.id);
            
            upperCylinderSelection = geometry.create(tags{7}, 'CylinderSelection');
            upperCylinderSelection.label(sprintf('Upper Cylinder Selection %d', obj.id));
            
            upperCylinderSelection.set('r', obj.bufferRadius+0.001);
            upperCylinderSelection.set('rin', '0');
            upperCylinderSelection.set('top', obj.bufferRadius+0.001);
            upperCylinderSelection.set('bottom', -0.001);
            upperCylinderSelection.set('pos', to_cell_array(bufferCollar));
            upperCylinderSelection.set('axis', to_cell_array(obj.boreholeAxis));
            upperCylinderSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the lower cylinder domain.
            
            tags{8} = sprintf('lower_cylinder_selection%d', obj.id);
            
            lowerCylinderSelection = geometry.create(tags{8}, 'CylinderSelection');
            lowerCylinderSelection.label(sprintf('Lower Cylinder Selection %d', obj.id));
            
            lowerCylinderSelection.set('r', obj.bufferRadius+0.001);
            lowerCylinderSelection.set('rin', '0');
            lowerCylinderSelection.set('top', obj.bufferRadius+0.001);
            lowerCylinderSelection.set('bottom', -0.001);
            lowerCylinderSelection.set('pos', to_cell_array(obj.boreholeFooter));
            lowerCylinderSelection.set('axis', to_cell_array(obj.boreholeAxis));
            lowerCylinderSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the upper and lower cylinders.
            
            tags{9} = sprintf('cylinders_selection%d', obj.id);
            
            cylindersSelection = geometry.create(tags{9}, 'UnionSelection');
            cylindersSelection.label(sprintf('Cylinders Selection %d', obj.id));
            cylindersSelection.set('input', {tags{7}, tags{8}});
            
            % Creates a selection containing the outer cap boundary.
            
            tags{10} = sprintf('outer_cap_selection%d', obj.id);
            
            outerCapSelection = geometry.create(tags{10}, 'CylinderSelection');
            outerCapSelection.label(sprintf('Outer Cap Selection %d', obj.id));
            
            outerCapSelection.set('entitydim', 2);
            outerCapSelection.set('r', obj.bufferRadius+0.001);
            outerCapSelection.set('rin', obj.boreholeRadius-0.001);
            outerCapSelection.set('top', +0.001);
            outerCapSelection.set('bottom', -0.001);
            outerCapSelection.set('pos', to_cell_array(obj.boreholeCollar));
            outerCapSelection.set('axis', to_cell_array(obj.boreholeAxis));
            %outerCapSelection.set('condition', 'allvertices');
            outerCapSelection.set('condition', 'inside'); %%% HACK %%%
            
            % Creates a selection containing the inner cap boundary.
            
            tags{11} = sprintf('inner_cap_selection%d', obj.id);
            
            innerCapSelection = geometry.create(tags{11}, 'CylinderSelection');
            innerCapSelection.label(sprintf('Inner Cap Selection %d', obj.id));
            
            innerCapSelection.set('entitydim', 2);
            innerCapSelection.set('r', obj.boreholeRadius+0.001);
            innerCapSelection.set('rin', 0);
            innerCapSelection.set('top', +0.001);
            innerCapSelection.set('bottom', -0.001);
            innerCapSelection.set('pos', to_cell_array(obj.boreholeCollar));
            innerCapSelection.set('axis', to_cell_array(obj.boreholeAxis));
            innerCapSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the top inlet boundary.
            
            tags{12} = sprintf('top_inlet_selection%d', obj.id);
            
            topInletSelection = geometry.create(tags{12}, 'CylinderSelection');
            topInletSelection.label(sprintf('Top Inlet Selection %d', obj.id));
            
            topInletSelection.set('entitydim', 2);
            topInletSelection.set('r', obj.boreholeRadius+0.001);
            topInletSelection.set('rin', obj.coaxialPipe.outerWallRadius-0.001);
            topInletSelection.set('top', +0.001);
            topInletSelection.set('bottom', -0.001);
            topInletSelection.set('pos', to_cell_array(obj.boreholeCollar));
            topInletSelection.set('axis', to_cell_array(obj.boreholeAxis));
            topInletSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the top outlet boundary.
            
            tags{13} = sprintf('top_outlet_selection%d', obj.id);
            
            topOutletSelection = geometry.create(tags{13}, 'CylinderSelection');
            topOutletSelection.label(sprintf('Top Outlet Selection %d', obj.id));
            
            topOutletSelection.set('entitydim', 2);
            topOutletSelection.set('r', obj.coaxialPipe.innerWallRadius+0.001);
            topOutletSelection.set('rin', '0');
            topOutletSelection.set('top', +0.001);
            topOutletSelection.set('bottom', -0.001);
            topOutletSelection.set('pos', to_cell_array(obj.boreholeCollar));
            topOutletSelection.set('axis', to_cell_array(obj.boreholeAxis));
            topOutletSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the bottom outlet boundary.
            
            tags{14} = sprintf('bottom_outlet_selection%d', obj.id);
            
            bottomOutletSelection = geometry.create(tags{14}, 'CylinderSelection');
            bottomOutletSelection.label(sprintf('Bottom Outlet Selection %d', obj.id));
            
            bottomOutletSelection.set('entitydim', 2);
            bottomOutletSelection.set('r', obj.boreholeRadius+0.001);
            bottomOutletSelection.set('rin', obj.coaxialPipe.outerWallRadius-0.001);
            bottomOutletSelection.set('top', +0.001);
            bottomOutletSelection.set('bottom', -0.001);
            bottomOutletSelection.set('pos', to_cell_array(obj.boreholeFooter));
            bottomOutletSelection.set('axis', to_cell_array(obj.boreholeAxis));
            bottomOutletSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the bottom inlet boundary.
            
            tags{15} = sprintf('bottom_inlet_selection%d', obj.id);
            
            bottomIntletSelection = geometry.create(tags{15}, 'CylinderSelection');
            bottomIntletSelection.label(sprintf('Bottom Inlet Selection %d', obj.id));
            
            bottomIntletSelection.set('entitydim', 2);
            bottomIntletSelection.set('r', obj.coaxialPipe.innerWallRadius+0.001);
            bottomIntletSelection.set('rin', '0');
            bottomIntletSelection.set('top', +0.001);
            bottomIntletSelection.set('bottom', -0.001);
            bottomIntletSelection.set('pos', to_cell_array(obj.boreholeFooter));
            bottomIntletSelection.set('axis', to_cell_array(obj.boreholeAxis));
            bottomIntletSelection.set('condition', 'allvertices');
            
        end
        
        function tags = createMesh(obj, geometry, mesh)
            
            % Creates a mesh for the inner cap of the borehole structure.
            
            tags{1} = sprintf('inner_cap_mesh%d', obj.id);
            
            innerCapMesh = mesh.create(tags{1}, 'FreeTri');
            innerCapMesh.label(sprintf('Inner Cap Mesh %d', obj.id));
            
            innerCapMesh.selection.named(sprintf('%s_inner_cap_selection%d', geometry.tag, obj.id));
            
            size = innerCapMesh.create('size', 'Size');
            size.set('hauto', CoaxialBoreholeHeatExchangerRecovery.INNER_CAP_ELEMENT_SIZE);
            size.set('custom', true);
            size.set('hmax', CoaxialBoreholeHeatExchangerRecovery.INNER_CAP_MAX_ELEMENT_SIZE);
            size.set('hmaxactive', true);
            
            % Creates a mesh for the outer cap of the borehole structure.
            
            tags{2} = sprintf('outer_cap_mesh%d', obj.id);
            
            outerCapMesh = mesh.create(tags{2}, 'FreeTri');
            outerCapMesh.label(sprintf('Outer Cap Mesh %d', obj.id));
            
            outerCapMesh.selection.named(sprintf('%s_outer_cap_selection%d', geometry.tag, obj.id));
            
            size = outerCapMesh.create('size', 'Size');
            size.set('hauto', CoaxialBoreholeHeatExchangerRecovery.OUTER_CAP_ELEMENT_SIZE);
            size.set('custom', true);
            size.set('hgrad', CoaxialBoreholeHeatExchangerRecovery.OUTER_CAP_MAX_ELEMENT_GROWTH_RATE);
            size.set('hgradactive', true);
            % size.set('hmax', 0.1);
            % size.set('hmaxactive', true);
            
            % Creates a swept mesh for the borehole structure.
            
            tags{3} = sprintf('swept_mesh%d', obj.id);
            
            sweptMesh = mesh.create(tags{3}, 'Sweep');
            sweptMesh.label(sprintf('Swept Mesh %d', obj.id));
            
            sweptMesh.selection.geom(geometry.tag, 3);
            sweptMesh.selection.named(sprintf('%s_borehole_structure_selection%d', geometry.tag, obj.id));
            
            distribution = sweptMesh.create('distribution', 'Distribution');
            distribution.set('type', 'predefined');
            distribution.set('elemcount', CoaxialBoreholeHeatExchangerRecovery.BOREHOLE_STRUCTURE_NUM_ELEMENTS);
            % distribution.set('elemratio', 10);
            distribution.set('elemratio', CoaxialBoreholeHeatExchangerRecovery.BOREHOLE_STRUCTURE_ELEMENT_RATIO);
            distribution.set('symmetric', true);
            
            % Creates meshes for the upper and lower cylinders.
            
            tags{4} = sprintf('cylinders_mesh%d', obj.id);
            
            cylindersMesh = mesh.create(tags{4}, 'FreeTet');
            cylindersMesh.label(sprintf('Cylinders Mesh %d', obj.id));
            
            cylindersMesh.selection.geom(geometry.tag, 3);
            cylindersMesh.selection.named(sprintf('%s_cylinders_selection%d', geometry.tag, obj.id));
            
            size = cylindersMesh.create('size', 'Size');
            size.set('hauto', CoaxialBoreholeHeatExchangerRecovery.CYLINDER_ELEMENT_SIZE);
            
        end
        
        function tags = createPhysics(obj, geometry, physics)
            
            % Creates outer fluid physics.
            
            tags{1} = sprintf('outer_fluid_physics%d', obj.id);
            
            fluid = physics.create(tags{1}, 'FluidHeatTransferModel', 3);
            fluid.label(sprintf('Outer Fluid Physics %d', obj.id));
            
            fluid.selection.named(sprintf('%s_outer_fluid_selection%d', geometry.tag, obj.id));
            %fluid.set('u', to_cell_array(obj.outerFluidVelocity));
            u = sprintf('if(is_discharging,%f,0)', obj.outerFluidVelocity(1));
            v = sprintf('if(is_discharging,%f,0)', obj.outerFluidVelocity(2));
            w = sprintf('if(is_discharging,%f,0)', obj.outerFluidVelocity(3));
            fluid.set('u', {u v w});
            fluid.set('k_mat', 'userdef');
            fluid.set('k', reshape(to_cell_array(obj.thermalConductivityTensor), 1, []));
            fluid.set('rho_mat', 'userdef');
            fluid.set('rho', obj.heatCarrierFluid.density);
            fluid.set('Cp_mat', 'userdef');
            fluid.set('Cp', obj.heatCarrierFluid.specificHeatCapacity);
            fluid.set('gamma_mat', 'userdef');
            fluid.set('gamma', 1);
            
            % Creates pipe wall physics.
            
            tags{2} = sprintf('pipe_wall_physics%d', obj.id);
            
            solid = physics.create(tags{2}, 'SolidHeatTransferModel', 3);
            solid.label(sprintf('Pipe Wall Physics %d', obj.id));
            
            solid.selection.named(sprintf('%s_pipe_wall_selection%d', geometry.tag, obj.id));
            solid.set('k_mat', 'userdef');
            solid.set('k', to_cell_array([obj.coaxialPipe.thermalConductivity 0 0 0 obj.coaxialPipe.thermalConductivity 0 0 0 obj.coaxialPipe.thermalConductivity]));
            solid.set('rho_mat', 'userdef');
            solid.set('rho', obj.coaxialPipe.density);
            solid.set('Cp_mat', 'userdef');
            solid.set('Cp', obj.coaxialPipe.specificHeatCapacity);
            
            % Creates inner fluid physics.
            
            tags{3} = sprintf('inner_fluid_physics%d', obj.id);
            
            fluid = physics.create(tags{3}, 'FluidHeatTransferModel', 3);
            fluid.label(sprintf('Inner Fluid Physics %d', obj.id));
            
            fluid.selection.named(sprintf('%s_inner_fluid_selection%d', geometry.tag, obj.id));
            %fluid.set('u', to_cell_array(obj.innerFluidVelocity));
            u = sprintf('if(is_discharging,%f,0)', obj.innerFluidVelocity(1));
            v = sprintf('if(is_discharging,%f,0)', obj.innerFluidVelocity(2));
            w = sprintf('if(is_discharging,%f,0)', obj.innerFluidVelocity(3));
            fluid.set('u', {u v w});
            fluid.set('k_mat', 'userdef');
            fluid.set('k', reshape(to_cell_array(obj.thermalConductivityTensor), 1, []));
            fluid.set('rho_mat', 'userdef');
            fluid.set('rho', obj.heatCarrierFluid.density);
            fluid.set('Cp_mat', 'userdef');
            fluid.set('Cp', obj.heatCarrierFluid.specificHeatCapacity);
            fluid.set('gamma_mat', 'userdef');
            fluid.set('gamma', 1);
            
        end
        
        function tags = createBoundaryConditions(obj, geometry, physics, inlet_temperature)
            
            % Creates top inlet temperature boundary condition.
            
            tags{1} = sprintf('top_inlet_temperature_bc%d', obj.id);
            
            boundaryCondition = physics.create(tags{1}, 'TemperatureBoundary', 2);
            boundaryCondition.label(sprintf('Top Inlet Temperature BC %d', obj.id));
            
            boundaryCondition.selection.named(sprintf('%s_top_inlet_selection%d', geometry.tag, obj.id));
            boundaryCondition.set('T0', inlet_temperature);
            
            % Creates bottom inlet temperature boundary condition.
            
            tags{2} = sprintf('bottom_inlet_temperature_bc%d', obj.id);
            
            boundaryCondition= physics.create(tags{2}, 'TemperatureBoundary', 2);
            boundaryCondition.label(sprintf('Bottom Inlet Temperature BC %d', obj.id));
            
            boundaryCondition.selection.named(sprintf('%s_bottom_inlet_selection%d', geometry.tag, obj.id));
            boundaryCondition.set('T0', sprintf('T_bottom%d', obj.id));
            
        end
        
        function tags = createOperators(obj, component, geometry)
            
            % Creates a wall integration operator.
            
            tags{1} = sprintf('borehole_wall_integration_operator%d', obj.id);
            
            operator = component.cpl.create(tags{1}, 'Integration');
            operator.label(sprintf('Borehole Wall Integration Operator %d', obj.id));
            operator.selection.geom(geometry.tag, 2);
            operator.selection.named(sprintf('%s_borehole_wall_selection%d', geometry.tag, obj.id));
            
            % Creates the top outlet average operator.
            
            tags{2} = sprintf('top_outlet_average_operator%d', obj.id);
            
            operator = component.cpl.create(tags{2}, 'Average');
            operator.label(sprintf('Top Average Operator %d', obj.id));
            operator.selection.geom(geometry.tag, 2);
            operator.selection.named(sprintf('%s_top_outlet_selection%d', geometry.tag, obj.id));
            
            % Creates the bottom outlet average operator.
            
            tags{3} = sprintf('bottom_outlet_average_operator%d', obj.id);
            
            operator = component.cpl.create(tags{3}, 'Average');
            operator.label(sprintf('Bottom Outlet Average Operator %d', obj.id));
            operator.selection.geom(geometry.tag, 2);
            operator.selection.named(sprintf('%s_bottom_outlet_selection%d', geometry.tag, obj.id));
            
            % Creates the top inlet average operator.
            
            tags{4} = sprintf('top_inlet_average_operator%d', obj.id);
            
            operator = component.cpl.create(tags{4}, 'Average');
            operator.label(sprintf('Top Inlet Average Operator %d', obj.id));
            operator.selection.geom(geometry.tag, 2);
            operator.selection.named(sprintf('%s_top_inlet_selection%d', geometry.tag, obj.id));
            
        end
        
        function createVariables(obj, variables, physics)
            
            variables.set(sprintf('T_inlet%d', obj.id), sprintf('top_inlet_average_operator%d(T)', obj.id));
            variables.set(sprintf('T_outlet%d', obj.id), sprintf('top_outlet_average_operator%d(T)', obj.id));
            variables.set(sprintf('T_bottom%d', obj.id), sprintf('bottom_outlet_average_operator%d(T)', obj.id));
            variables.set(sprintf('A_wall%d', obj.id), sprintf('borehole_wall_integration_operator%d(1)', obj.id));
            variables.set(sprintf('Q_wall%d', obj.id), sprintf('symmetry_factor%d*borehole_wall_integration_operator%d(%s.ndflux)', obj.id, obj.id, physics.tag));
            variables.set(sprintf('symmetry_factor%d', obj.id), sprintf('2*pi*%s[m]*%s[m]/A_wall%d', to_cell_array(obj.boreholeRadius), to_cell_array(obj.boreholeLength), obj.id));
            
        end
        
    end
    
    %     methods (Static)
    %
    %         function CreateField(file_name)
    %
    %             % Reads the borehole field configuration:
    %             % starting point (x, y, z) and ending point (x, y, z) and
    %             % borehole factor.
    %
    %             field_config = load(file_name);
    %
    %             sx = field_config(:, 1);
    %             sy = field_config(:, 2);
    %             sz = field_config(:, 3);
    %
    %             ex = field_config(:, 4);
    %             ey = field_config(:, 5);
    %             ez = field_config(:, 6);
    %
    %             theta = acos(z ./ r);
    %             phi = atan2(y, x);
    %
    %             tilt = 90 - 180 * theta / pi;
    %             azim = 180 * phi / pi;
    %
    %             i = [];
    %
    %             for j = 1:length(tilt)
    %                 if (abs(azim(j)) < 1e-6) || (abs(azim(j)-90) < 1e-6)
    %                     i = [i j];
    %                 elseif 0 <= azim(j) && azim(j) <= 90
    %                     i = [i j];
    %                 end
    %             end
    %
    %             tilt = tilt(i);
    %             azim = azim(i);
    %
    %         end
    %
    %     end
    
end

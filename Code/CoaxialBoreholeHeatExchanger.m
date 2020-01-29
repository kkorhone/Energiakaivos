classdef CoaxialBoreholeHeatExchanger
    
    properties
        id
        location, tilt, azimuth, diameter, length, offset, bufferRadius, heatCarrierFluid, coaxialPipe, mirrorPlanes
        radius, axis, thermalConductivityTensor
        outerFluidVelocity, innerFluidVelocity
    end
    
    methods
        
        function obj = CoaxialBoreholeHeatExchanger(location, tilt, azimuth, diameter, length, offset, bufferRadius, heatCarrierFluid, coaxialPipe, mirrorPlanes)
            
            persistent id
            
            if isempty(id)
                id = 1;
            else
                id = id + 1;
            end
            
            obj.id = id;
            
            obj.location = location;
            obj.tilt = tilt;
            obj.azimuth = azimuth;
            obj.diameter = diameter;
            obj.length = length;
            obj.offset = offset;
            obj.bufferRadius = bufferRadius;
            obj.heatCarrierFluid = heatCarrierFluid;
            obj.coaxialPipe = coaxialPipe;
            
            obj.radius = 0.5 * diameter;
            
            if nargin == 9
                obj.mirrorPlanes = [];
            else
                obj.mirrorPlanes = mirrorPlanes;
            end
            
            theta = pi * tilt / 180;
            phi = pi * azimuth / 180;
            
            rotationMatrix = [cos(phi)*cos(theta) -sin(phi) -sin(theta)*cos(phi); sin(phi)*cos(theta) cos(phi) -sin(phi)*sin(theta); sin(theta) 0 cos(theta)];
            
            obj.axis = transpose(rotationMatrix * transpose([1 0 0]));
            
            thermalConductivityTensor = [[heatCarrierFluid.thermalConductivity, 0, 0]; [0, 1000, 0]; [0, 0, 1000]];
            
            obj.thermalConductivityTensor = rotationMatrix * thermalConductivityTensor * inv(rotationMatrix);
            
            outerFluidArea = pi * obj.radius^2 - pi * coaxialPipe.outerWallRadius^2;
            innerFluidArea = pi * coaxialPipe.innerWallRadius^2;
            
            obj.outerFluidVelocity = heatCarrierFluid.flowRate / outerFluidArea * obj.axis;
            obj.innerFluidVelocity = heatCarrierFluid.flowRate / innerFluidArea * -obj.axis;
            
        end
        
        function createWorkPlaneStructure(obj, workPlane, radiuses)
            
            circleTags = cell(size(radiuses));
            
            for i = 1:numel(radiuses)
                circleTags{i} = sprintf('circle%d', i);
                circle = workPlane.geom.create(circleTags{i}, 'Circle');
                circle.label(sprintf('Circle %d', i));
                circle.set('r', radiuses(i)');
            end
            
            polygonTags = cell(size(obj.mirrorPlanes));
            
            for i = 1:numel(obj.mirrorPlanes)
                polygonTags{i} = obj.mirrorPlanes{i}.createCutStructure(workPlane, max(radiuses));
            end
            
            if ~isempty(obj.mirrorPlanes)
                difference = workPlane.geom.create('difference', 'Difference');
                difference.selection('input').set(circleTags);
                difference.selection('input2').set(polygonTags);
            end
            
        end
        
        function createGeometry(obj, geometry)
            
            % Creates the borehole heat exchanger structure.
            
            boreholeCollar = obj.location + obj.offset * obj.axis;
            
            workPlaneTag = sprintf('work_plane_cbhe_structure%d', obj.id);
            
            workPlane = geometry.create(workPlaneTag, 'WorkPlane');
            workPlane.label(sprintf('Work Plane for CBHE Structure %d', obj.id));
            
            workPlane.set('planetype', 'normalvector');
            workPlane.set('normalcoord', to_cell_array(boreholeCollar));
            workPlane.set('normalvector', to_cell_array(obj.axis));
            
            workPlane.set('unite', true);
            
            obj.createWorkPlaneStructure(workPlane, [obj.bufferRadius, obj.radius, obj.coaxialPipe.outerWallRadius, obj.coaxialPipe.innerWallRadius]);
            
            extrusionTag = sprintf('extrusion_cbhe_structure%d', obj.id);
            
            extrusion = geometry.create(extrusionTag, 'Extrude');
            extrusion.label(sprintf('Extrusion for CBHE Structure Work Plane %d', obj.id));
            
            extrusion.setIndex('distance', obj.length, 0);
            extrusion.selection('input').set(workPlaneTag);
            
            % Creates the upper cylinder above the borehole heat exchanger.
            
            bufferCollar = obj.location + (obj.offset - obj.bufferRadius) * obj.axis;
            
            workPlaneTag = sprintf('work_plane_upper_cylinder%d', obj.id);
            
            workPlane = geometry.create(workPlaneTag, 'WorkPlane');
            workPlane.label(sprintf('Work Plane for Upper Cylinder %d', obj.id));
            
            workPlane.set('planetype', 'normalvector');
            workPlane.set('normalcoord', to_cell_array(bufferCollar));
            workPlane.set('normalvector', to_cell_array(obj.axis));
            
            workPlane.set('unite', true);
            
            obj.createWorkPlaneStructure(workPlane, obj.bufferRadius);
            
            extrusionTag = sprintf('extrusion_upper_cylinder%d', obj.id);
            
            extrusion = geometry.create(extrusionTag, 'Extrude');
            extrusion.label(sprintf('Extrusion for Upper Cylinder Work Plane %d', obj.id));
            
            extrusion.setIndex('distance', obj.bufferRadius, 0);
            extrusion.selection('input').set(workPlaneTag);
            
            % Creates the lower cylinder below the borehole heat exchanger.
            
            boreholeFooter = obj.location + (obj.offset + obj.length) * obj.axis;
            
            workPlaneTag = sprintf('work_plane_lower_cylinder%d', obj.id);
            
            workPlane = geometry.create(workPlaneTag, 'WorkPlane');
            workPlane.label(sprintf('Work Plane for Lower Cylinder %d', obj.id));
            
            workPlane.set('planetype', 'normalvector');
            workPlane.set('normalcoord', to_cell_array(boreholeFooter));
            workPlane.set('normalvector', to_cell_array(obj.axis));
            
            workPlane.set('unite', true);
            
            obj.createWorkPlaneStructure(workPlane, obj.bufferRadius);
            
            extrusionTag = sprintf('extrusion_lower_cylinder%d', obj.id);
            
            extrusion = geometry.create(extrusionTag, 'Extrude');
            extrusion.label(sprintf('Extrusion for Lower Cylinder Work Plane %d', obj.id));
            
            extrusion.setIndex('distance', obj.bufferRadius, 0);
            extrusion.selection('input').set(workPlaneTag);
            
            fprintf(1, 'Done.\n');
            
        end
        
        function createSelections(obj, geometry)
            
            % Creates a selection containing the buffer zone domain.
            
            boreholeCollar = obj.location + obj.offset * obj.axis;
            
            bufferZoneSelectionTag = sprintf('buffer_zone_selection%d', obj.id);
            
            bufferZoneSelection = geometry.create(bufferZoneSelectionTag, 'CylinderSelection');
            bufferZoneSelection.label(sprintf('Buffer Zone Selection %d', obj.id));
            
            bufferZoneSelection.set('r', obj.bufferRadius+0.001);
            bufferZoneSelection.set('rin', obj.radius-0.001);
            bufferZoneSelection.set('top', obj.length+0.001);
            bufferZoneSelection.set('bottom', -0.001);
            bufferZoneSelection.set('pos', to_cell_array(boreholeCollar));
            bufferZoneSelection.set('axis', to_cell_array(obj.axis));
            bufferZoneSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the outer fluid domain.
            
            boreholeFooter = obj.location + (obj.offset + obj.length) * obj.axis;
            bufferCollar = obj.location + (obj.offset - obj.bufferRadius) * obj.axis;
            
            outerFluidSelectionTag = sprintf('outer_fluid_selection%d', obj.id);
            
            outerFluidSelection = geometry.create(outerFluidSelectionTag, 'CylinderSelection');
            outerFluidSelection.label(sprintf('Outer Fluid Selection %d', obj.id));
            
            outerFluidSelection.set('r', obj.radius+0.001);
            outerFluidSelection.set('rin', obj.coaxialPipe.outerWallRadius-0.001);
            outerFluidSelection.set('top', obj.length+0.001);
            outerFluidSelection.set('bottom', -0.001);
            outerFluidSelection.set('pos', to_cell_array(boreholeCollar));
            outerFluidSelection.set('axis', to_cell_array(obj.axis));
            outerFluidSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the pipe wall domain.
            
            pipeWallSelectionTag = sprintf('pipe_wall_selection%d', obj.id);
            
            pipeWallSelection = geometry.create(pipeWallSelectionTag, 'CylinderSelection');
            pipeWallSelection.label(sprintf('Pipe Wall Selection %d', obj.id));
            
            pipeWallSelection.set('r', obj.coaxialPipe.outerWallRadius+0.001);
            %pipeWallSelection.set('rin', obj.inner_pipe_radius-0.001);
            pipeWallSelection.set('rin', +0.001); %%% HACK %%%
            pipeWallSelection.set('top', obj.length+0.001);
            pipeWallSelection.set('bottom', -0.001);
            pipeWallSelection.set('pos', to_cell_array(boreholeCollar));
            pipeWallSelection.set('axis', to_cell_array(obj.axis));
            %pipeWallSelection.set('condition', 'allvertices');
            pipeWallSelection.set('condition', 'inside'); %%% HACK %%%
            
            % Creates a selection containing the inner fluid domain.
            
            innerFluidSelectionTag = sprintf('inner_fluid_selection%d', obj.id);
            
            innerFluidSelection = geometry.create(innerFluidSelectionTag, 'CylinderSelection');
            innerFluidSelection.label(sprintf('Inner Fluid Selection %d', obj.id));
            
            innerFluidSelection.set('r', obj.coaxialPipe.innerWallRadius+0.001);
            innerFluidSelection.set('rin', '0');
            innerFluidSelection.set('top', obj.length+0.001);
            innerFluidSelection.set('bottom', -0.001);
            innerFluidSelection.set('pos', to_cell_array(boreholeCollar));
            innerFluidSelection.set('axis', to_cell_array(obj.axis));
            innerFluidSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the parts of the borehole structure.
            
            boreholeStructureSelectionTag = sprintf('borehole_structure_selection%d', obj.id);
            
            boreholeStructureSelection = geometry.create(boreholeStructureSelectionTag, 'UnionSelection');
            boreholeStructureSelection.set('input', {bufferZoneSelectionTag outerFluidSelectionTag pipeWallSelectionTag innerFluidSelectionTag});
            
            % Creates a selection containing the borehole wall boundary.
            
            boreholeWallSelectionTag = sprintf('borehole_wall_selection%d', obj.id);
            
            boreholeWallSelection = geometry.create(boreholeWallSelectionTag, 'CylinderSelection');
            boreholeWallSelection.label(sprintf('Borehole Wall Selection %d', obj.id));
            
            boreholeWallSelection.set('entitydim', 2);
            boreholeWallSelection.set('r', obj.radius+0.001);
            boreholeWallSelection.set('rin', obj.radius-0.001);
            boreholeWallSelection.set('top', obj.length+0.001);
            boreholeWallSelection.set('bottom', -0.001);
            boreholeWallSelection.set('pos', to_cell_array(boreholeCollar));
            boreholeWallSelection.set('axis', to_cell_array(obj.axis));
            boreholeWallSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the upper cylinder domain.
            
            upperCylinderSelectionTag = sprintf('upper_cylinder_selection%d', obj.id);
            
            upperCylinderSelection = geometry.create(upperCylinderSelectionTag, 'CylinderSelection');
            upperCylinderSelection.label(sprintf('Upper Cylinder Selection %d', obj.id));
            
            upperCylinderSelection.set('r', obj.bufferRadius+0.001);
            upperCylinderSelection.set('rin', '0');
            upperCylinderSelection.set('top', obj.bufferRadius+0.001);
            upperCylinderSelection.set('bottom', -0.001);
            upperCylinderSelection.set('pos', to_cell_array(bufferCollar));
            upperCylinderSelection.set('axis', to_cell_array(obj.axis));
            upperCylinderSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the lower cylinder domain.
            
            lowerCylinderSelectionTag = sprintf('lower_cylinder_selection%d', obj.id);
            
            lowerCylinderSelection = geometry.create(lowerCylinderSelectionTag, 'CylinderSelection');
            lowerCylinderSelection.label(sprintf('Lower Cylinder Selection %d', obj.id));
            
            lowerCylinderSelection.set('r', obj.bufferRadius+0.001);
            lowerCylinderSelection.set('rin', '0');
            lowerCylinderSelection.set('top', obj.bufferRadius+0.001);
            lowerCylinderSelection.set('bottom', -0.001);
            lowerCylinderSelection.set('pos', to_cell_array(boreholeFooter));
            lowerCylinderSelection.set('axis', to_cell_array(obj.axis));
            lowerCylinderSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the upper and lower cylinders.
            
            cylindersSelectionTag = sprintf('cylinders_selection%d', obj.id);
            
            cylindersSelection = geometry.create(cylindersSelectionTag, 'UnionSelection');
            cylindersSelection.set('input', {upperCylinderSelectionTag lowerCylinderSelectionTag});
            
            % Creates a selection containing the outer cap boundary.
            
            outerCapSelectionTag = sprintf('outer_cap_selection%d', obj.id);
            
            outerCapSelection = geometry.create(outerCapSelectionTag, 'CylinderSelection');
            outerCapSelection.label(sprintf('Outer Cap Selection %d', obj.id));
            
            outerCapSelection.set('entitydim', 2);
            outerCapSelection.set('r', obj.bufferRadius+0.001);
            outerCapSelection.set('rin', obj.radius-0.001);
            outerCapSelection.set('top', +0.001);
            outerCapSelection.set('bottom', -0.001);
            outerCapSelection.set('pos', to_cell_array(boreholeCollar));
            outerCapSelection.set('axis', to_cell_array(obj.axis));
            %outerCapSelection.set('condition', 'allvertices');
            outerCapSelection.set('condition', 'inside'); %%% HACK %%%
            
            % Creates a selection containing the inner cap boundary.
            
            innerCapSelectionTag = sprintf('inner_cap_selection%d', obj.id);
            
            innerCapSelection = geometry.create(innerCapSelectionTag, 'CylinderSelection');
            innerCapSelection.label(sprintf('Inner Cap Selection %d', obj.id));
            
            innerCapSelection.set('entitydim', 2);
            innerCapSelection.set('r', obj.radius+0.001);
            innerCapSelection.set('rin', 0);
            innerCapSelection.set('top', +0.001);
            innerCapSelection.set('bottom', -0.001);
            innerCapSelection.set('pos', to_cell_array(boreholeCollar));
            innerCapSelection.set('axis', to_cell_array(obj.axis));
            innerCapSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the top inlet boundary.
            
            topInletSelectionTag = sprintf('top_inlet_selection%d', obj.id);
            
            topInletSelection = geometry.create(topInletSelectionTag, 'CylinderSelection');
            topInletSelection.label(sprintf('Top Inlet Selection %d', obj.id));
            
            topInletSelection.set('entitydim', 2);
            topInletSelection.set('r', obj.radius+0.001);
            topInletSelection.set('rin', obj.coaxialPipe.outerWallRadius-0.001);
            topInletSelection.set('top', +0.001);
            topInletSelection.set('bottom', -0.001);
            topInletSelection.set('pos', to_cell_array(boreholeCollar));
            topInletSelection.set('axis', to_cell_array(obj.axis));
            topInletSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the top outlet boundary.
            
            topOutletSelectionTag = sprintf('top_outlet_selection%d', obj.id);
            
            topOutletSelection = geometry.create(topOutletSelectionTag, 'CylinderSelection');
            topOutletSelection.label(sprintf('Top Outlet Selection %d', obj.id));
            
            topOutletSelection.set('entitydim', 2);
            topOutletSelection.set('r', obj.coaxialPipe.innerWallRadius+0.001);
            topOutletSelection.set('rin', '0');
            topOutletSelection.set('top', +0.001);
            topOutletSelection.set('bottom', -0.001);
            topOutletSelection.set('pos', to_cell_array(boreholeCollar));
            topOutletSelection.set('axis', to_cell_array(obj.axis));
            topOutletSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the bottom outlet boundary.
            
            bottomOutletSelectionTag = sprintf('bottom_outlet_selection%d', obj.id);
            
            bottomOutletSelection = geometry.create(bottomOutletSelectionTag, 'CylinderSelection');
            bottomOutletSelection.label(sprintf('Bottom Outlet Selection %d', obj.id));
            
            bottomOutletSelection.set('entitydim', 2);
            bottomOutletSelection.set('r', obj.radius+0.001);
            bottomOutletSelection.set('rin', obj.coaxialPipe.outerWallRadius-0.001);
            bottomOutletSelection.set('top', +0.001);
            bottomOutletSelection.set('bottom', -0.001);
            bottomOutletSelection.set('pos', to_cell_array(boreholeFooter));
            bottomOutletSelection.set('axis', to_cell_array(obj.axis));
            bottomOutletSelection.set('condition', 'allvertices');
            
            % Creates a selection containing the bottom inlet boundary.
            
            bottomIntletSelectionTag = sprintf('bottom_inlet_selection%d', obj.id);
            
            bottomIntletSelection = geometry.create(bottomIntletSelectionTag, 'CylinderSelection');
            bottomIntletSelection.label(sprintf('Bottom Inlet Selection %d', obj.id));
            
            bottomIntletSelection.set('entitydim', 2);
            bottomIntletSelection.set('r', obj.coaxialPipe.innerWallRadius+0.001);
            bottomIntletSelection.set('rin', '0');
            bottomIntletSelection.set('top', +0.001);
            bottomIntletSelection.set('bottom', -0.001);
            bottomIntletSelection.set('pos', to_cell_array(boreholeFooter));
            bottomIntletSelection.set('axis', to_cell_array(obj.axis));
            bottomIntletSelection.set('condition', 'allvertices');
            
            fprintf(1, 'Done.\n');
            
        end
        
        function createMesh(obj, mesh)
            
            % Creates a mesh for the inner cap of the borehole structure.
            
            innerCapMeshTag = sprintf('inner_cap_mesh%d', obj.id);
            
            innerCapMesh = mesh.create(innerCapMeshTag, 'FreeTri');
            innerCapMesh.label(sprintf('Inner Cap Mesh %d', obj.id));
            
            innerCapMesh.selection.named(sprintf('geometry_inner_cap_selection%d', obj.id));
            
            size = innerCapMesh.create('size', 'Size');
            size.set('hauto', 1);
            size.set('custom', true);
            size.set('hmax', 0.015);
            size.set('hmaxactive', true);
            
            % Creates a mesh for the outer cap of the borehole structure.
            
            outerCapMeshTag = sprintf('outer_cap_mesh%d', obj.id);
            
            outerCapMesh = mesh.create(outerCapMeshTag, 'FreeTri');
            outerCapMesh.label(sprintf('Outer Cap Mesh %d', obj.id));
            
            outerCapMesh.selection.named(sprintf('geometry_outer_cap_selection%d', obj.id));
            
            size = outerCapMesh.create('size', 'Size');
            size.set('hauto', 1);
            size.set('custom', 'on');
            size.set('hgrad', 1.2);
            size.set('hgradactive', true);
            size.set('hmax', 0.1);
            size.set('hmaxactive', true);
            
            % Creates a swept mesh for the borehole structure.
            
            sweptMeshTag = sprintf('swept_mesh%d', obj.id);
            
            sweptMesh = mesh.create(sweptMeshTag, 'Sweep');
            sweptMesh.label(sprintf('Swept Mesh %d', obj.id));
            
            sweptMesh.selection.geom('geometry', 3);
            sweptMesh.selection.named(sprintf('geometry_borehole_structure_selection%d', obj.id));
            
            distribution = sweptMesh.create('distribution', 'Distribution');
            distribution.set('type', 'predefined');
            distribution.set('elemcount', 300);
            distribution.set('elemratio', 10);
            distribution.set('symmetric', true);
            
            % Creates meshes for the upper and lower cylinders.
            
            cylindersMeshTag = sprintf('cylinders_mesh%d', obj.id);
            
            cylindersMesh = mesh.create(cylindersMeshTag, 'FreeTet');
            cylindersMesh.label(sprintf('Cylinders Mesh %d', obj.id));
            
            cylindersMesh.selection.geom('geometry', 3);
            cylindersMesh.selection.named(sprintf('geometry_cylinders_selection%d', obj.id));
            
            size = cylindersMesh.create('size', 'Size');
            size.set('hauto', 3);
            
        end
        
        function createPhysics(obj, physics)
            
            % Creates outer fluid physics.
            
            outerFluidPhysicsTag = sprintf('outer_fluid_physics%d', obj.id);
            
            outerFluidPhysics = physics.create(outerFluidPhysicsTag, 'FluidHeatTransferModel', 3);
            outerFluidPhysics.label(sprintf('Outer Fluid Physics %d', obj.id));
            
            outerFluidPhysics.selection.named(sprintf('geometry_outer_fluid_selection%d', obj.id));
            outerFluidPhysics.set('u', to_cell_array(obj.outerFluidVelocity));
            outerFluidPhysics.set('k_mat', 'userdef');
            outerFluidPhysics.set('k', reshape(to_cell_array(obj.thermalConductivityTensor), 1, []));
            outerFluidPhysics.set('rho_mat', 'userdef');
            outerFluidPhysics.set('rho', obj.heatCarrierFluid.density);
            outerFluidPhysics.set('Cp_mat', 'userdef');
            outerFluidPhysics.set('Cp', obj.heatCarrierFluid.specificHeatCapacity);
            outerFluidPhysics.set('gamma_mat', 'userdef');
            outerFluidPhysics.set('gamma', 1);
            
            % Creates pipe wall physics.
            
            pipeWallPhysicsTag = sprintf('pipe_wall_physics%d', obj.id);
            
            pipeWallPhysics = physics.create(pipeWallPhysicsTag, 'SolidHeatTransferModel', 3);
            pipeWallPhysics.label(sprintf('Pipe Wall Physics %d', obj.id));
            
            pipeWallPhysics.selection.named(sprintf('geometry_pipe_wall_selection%d', obj.id));
            pipeWallPhysics.set('k_mat', 'userdef');
            pipeWallPhysics.set('k', to_cell_array([obj.coaxialPipe.thermalConductivity 0 0 0 obj.coaxialPipe.thermalConductivity 0 0 0 obj.coaxialPipe.thermalConductivity]));
            pipeWallPhysics.set('rho_mat', 'userdef');
            pipeWallPhysics.set('rho', obj.coaxialPipe.density);
            pipeWallPhysics.set('Cp_mat', 'userdef');
            pipeWallPhysics.set('Cp', obj.coaxialPipe.specificHeatCapacity);
            
            % Creates inner fluid physics.
            
            innerFluidPhysicsTag = sprintf('inner_fluid_physics%d', obj.id);
            
            innerFluidPhysics = physics.create(innerFluidPhysicsTag, 'FluidHeatTransferModel', 3);
            innerFluidPhysics.label(sprintf('Inner Fluid Physics %d', obj.id));
            
            innerFluidPhysics.selection.named(sprintf('geometry_inner_fluid_selection%d', obj.id));
            innerFluidPhysics.set('u', to_cell_array(obj.innerFluidVelocity));
            innerFluidPhysics.set('k_mat', 'userdef');
            innerFluidPhysics.set('k', reshape(to_cell_array(obj.thermalConductivityTensor), 1, []));
            innerFluidPhysics.set('rho_mat', 'userdef');
            innerFluidPhysics.set('rho', obj.heatCarrierFluid.density);
            innerFluidPhysics.set('Cp_mat', 'userdef');
            innerFluidPhysics.set('Cp', obj.heatCarrierFluid.specificHeatCapacity);
            innerFluidPhysics.set('gamma_mat', 'userdef');
            innerFluidPhysics.set('gamma', 1);
            
        end
        
        function createBoundaryConditions(obj, physics, inlet_temperature)
            
            % Creates top inlet temperature boundary condition.
            
            topInletTemperatureBCTag = sprintf('top_inlet_temperature_bc%d', obj.id);
            
            topInletTemperatureBC = physics.create(topInletTemperatureBCTag, 'TemperatureBoundary', 2);
            topInletTemperatureBC.label(sprintf('Top Inlet Temperature BC %d', obj.id));
            
            topInletTemperatureBC.selection.named(sprintf('geometry_top_inlet_selection%d', obj.id));
            topInletTemperatureBC.set('T0', inlet_temperature);
            
            % Creates bottom inlet temperature boundary condition.
            
            bottomInletTemperatureBCTag = sprintf('bottom_inlet_temperature_bc%d', obj.id);
            
            bottomInletTemperatureBC = physics.create(bottomInletTemperatureBCTag, 'TemperatureBoundary', 2);
            bottomInletTemperatureBC.label(sprintf('Bottom Inlet Temperature BC %d', obj.id));
            
            bottomInletTemperatureBC.selection.named(sprintf('geometry_bottom_inlet_selection%d', obj.id));
            bottomInletTemperatureBC.set('T0', sprintf('T_bottom%d', obj.id));
            
        end
        
        function createOperators(obj, component, geometry)
            
            % Creates a wall integration operator.
            
            tag = sprintf('borehole_wall_integration_operator%d', obj.id);
            
            operator = component.cpl.create(tag, 'Integration');
            operator.label(sprintf('Borehole Wall Integration Operator %d', obj.id));
            operator.selection.geom(geometry.tag, 2);
            operator.selection.named(sprintf('geometry_borehole_wall_selection%d', obj.id));
            
            % Creates the top outlet average operator.
            
            tag = sprintf('top_outlet_average_operator%d', obj.id);
            
            operator = component.cpl.create(tag, 'Average');
            operator.label(sprintf('Top Average Operator %d', obj.id));
            operator.selection.geom(geometry.tag, 2);
            operator.selection.named(sprintf('geometry_top_outlet_selection%d', obj.id));
            
            % Creates the bottom outlet average operator.
            
            tag = sprintf('bottom_outlet_average_operator%d', obj.id);
            
            operator = component.cpl.create(tag, 'Average');
            operator.label(sprintf('Bottom Average Operator %d', obj.id));
            operator.selection.geom(geometry.tag, 2);
            operator.selection.named(sprintf('geometry_bottom_outlet_selection%d', obj.id));
            
        end
        
        function createVariables(obj, variables, physics)
            
            variables.set(sprintf('T_outlet%d', obj.id), sprintf('top_outlet_average_operator%d(T)', obj.id));
            variables.set(sprintf('T_bottom%d', obj.id), sprintf('bottom_outlet_average_operator%d(T)', obj.id));
            variables.set(sprintf('A_wall%d', obj.id), sprintf('borehole_wall_integration_operator%d(1)', obj.id));
            variables.set(sprintf('Q_wall%d', obj.id), sprintf('symmetry_factor%d*borehole_wall_integration_operator%d(%s.ndflux)', obj.id, obj.id, physics.tag));
            variables.set(sprintf('symmetry_factor%d', obj.id), sprintf('2*pi*%s[m]*%s[m]/A_wall%d', to_cell_array(obj.radius), to_cell_array(obj.length), obj.id));
            
        end
        
    end
    
end

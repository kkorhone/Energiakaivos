function [sx, sy, sz, ex, ey, ez, fac] = calc_half_symmetry(field)

% x_min = min(field(:, 1))
% x_max = max(field(:, 1))

% y_min = min(field(:, 2))
% y_max = max(field(:, 2))

% =========================================================================
% Test symmetry against y axis.
% =========================================================================

half_field = [];
half_factors = [];

for i = 1:size(field, 1)
    if abs(field(i,1)) < 1e-6
        % BHE is located on the x axis.
        half_field(end+1, 1:6) = field(i, 1:6);
        half_factors(end+1) = 1;
    elseif field(i,1) >= 0
        % BHE is located on the half space x > 0.
        half_field(end+1, 1:6) = field(i, 1:6);
        half_factors(end+1) = 2;
    end
end

% Dataset of symmetric and reflected BHEs.
check_field = [half_field];

% Symmetry plane normal.
normal = [1 0 0];

for i = 1:size(half_field, 1)
    % Reflects the current BHE.
    collar = half_field(i, 1:3) - 2 * dot(half_field(i, 1:3), normal) * normal;
    footer = half_field(i, 4:6) - 2 * dot(half_field(i, 4:6), normal) * normal;
    fprintf(1,'%.6f %.6f\n', sqrt(collar(1)^2+collar(2)^2+collar(3)^2),    sqrt(footer(1)^2+footer(2)^2+footer(3)^2));
    % Checks if the reflected BHE is already in the dataset.
    already = 0;
    for j = 1:size(check_field, 1)
        collar_dx = collar(1) - check_field(j, 1);
        collar_dy = collar(2) - check_field(j, 2);
        collar_dz = collar(3) - check_field(j, 3);
        footer_dx = footer(1) - check_field(j, 4);
        footer_dy = footer(2) - check_field(j, 5);
        footer_dz = footer(3) - check_field(j, 6);
        collar_dist = sqrt(collar_dx^2 + collar_dy^2 + collar_dz^2);
        footer_dist = sqrt(footer_dx^2 + footer_dy^2 + footer_dz^2);
        if (collar_dist < 1e-6) && (footer_dist < 1e-6)
            already = 1;
            break
        end
    end
    % Saves the reflected BHE if it is not already in the dataset.
    if ~already
        check_field(end+1, 1:6) = [collar, footer];
    end
end

figure
hold on
if size(field, 1) == size(check_field, 1)
    symmetry = 1;
    % Checks each BHE in the field against each BHE in the dataset.
    for i = 1:size(field, 1)
        field_collar = field(i, 1:3);
        field_footer = field(i, 4:6);
        plot3(field_collar(1), field_collar(2), field_collar(3), 'r.', 'markersize', 20);
        plot3(field_footer(1), field_footer(2), field_footer(3), 'r.', 'markersize', 20);
        found = 0;
        for j = 1:size(check_field, 1)
            check_collar = check_field(j, 1:3);
            check_footer = check_field(j, 4:6);
            collar_dx = field_collar(1) - check_collar(1);
            collar_dy = field_collar(2) - check_collar(2);
            collar_dz = field_collar(3) - check_collar(3);
            footer_dx = field_footer(1) - check_footer(1);
            footer_dy = field_footer(2) - check_footer(2);
            footer_dz = field_footer(3) - check_footer(3);
            collar_dist = sqrt(collar_dx^2 + collar_dy^2 + collar_dz^2);
            footer_dist = sqrt(footer_dx^2 + footer_dy^2 + footer_dz^2);
            if (collar_dist < 1e-6) && (footer_dist < 1e-6)
                plot3(check_collar(1), check_collar(2), check_collar(3), 'b.', 'markersize', 20);
                plot3(check_footer(1), check_footer(2), check_footer(3), 'b.', 'markersize', 20);
                found = 1;
                break
            end
        end
        if ~found
            symmetry = 0;
            break
        end
    end
else
    symmetry = 0;
end
hold off

figure
hold on
for i = 1:size(field,1)
    plot3([field(i,1) field(i,4)], [field(i,2) field(i,5)], [field(i,3) field(i,6)], 'b-')
    plot3(field(i,1), field(i,2), field(i,3), 'b.', 'markersize', 20)
    plot3(field(i,4), field(i,5), field(i,6), 'b.', 'markersize', 20)
end
for i = 1:size(check_field,1)
   plot3([check_field(i,1) check_field(i,4)], [check_field(i,2) check_field(i,5)], [check_field(i,3) check_field(i,6)], 'r-')
   plot3(check_field(i,1), check_field(i,2), check_field(i,3), 'r.', 'markersize', 20)
   plot3(check_field(i,4), check_field(i,5), check_field(i,6), 'r.', 'markersize', 20)
end
hold off

if symmetry
    sum(half_factors)
    size(field, 1)
    title(sprintf('Symmetry (%d of %d BHEs)', size(half_field,1), size(field,1)))
else
    title('Asymmetry')
end

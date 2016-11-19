

function [boundaries] = surf_border(table_size)


    boundaries = round([
        table_size(1) * (153/640)
        table_size(2) * (136/1136)
        table_size(1) * (585/640)
        table_size(2) * (1001/1136)
    ]);


    %{
    boundaries = [
        boundaries(2)
        boundaries(1)
        boundaries(4)-boundaries(2)
        boundaries(3)-boundaries(1)
    ];
    %}
end

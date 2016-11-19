   

% make anything in format as [r,c] = [y,x] !! much easier to understand and
% is correct!

for gt= 21:21
    
% functionize everything you can -> too many un-usable variables in the
    % workspace

    surface = imread(strcat('tab', int2str(gt), '.png'));
    aimer = imread('pos1.png'); % pos2 in my pc

    wb1 = imread('wb1.png');
    wb2 = imread('wb2.png');
    %wb3 = imread('wb3.png');
    wb4 = imread('wb4.png');

    [table_rows, table_cols] = size(rgb2gray(surface));

    aimer_rows = table_rows * (29/640);
    aimer_cols = table_cols * (29/1136);
    aim_rad = round((aimer_rows/2 + aimer_cols/2) /2);

    ball_rows = table_rows * (5/128);
    ball_cols = table_cols * (25/1136);
    ball_rad = round((ball_cols/2 + ball_rows/2) /2);


    aimer = imresize(aimer, [aimer_rows, aimer_cols]);

    wb1 = imresize(wb1, [ball_rows, ball_cols]);
    wb2 = imresize(wb2, [ball_rows, ball_cols]);
    %wb3 = imresize(wb3, [ball_rows, ball_cols]);
    wb4 = imresize(wb4, [ball_rows, ball_cols]);

    aimer_gray = rgb2gray(aimer);

    % [xmin, ymin, width, height]
    border = surf_border([table_rows, table_cols]);

    surface_gray = rgb2gray(surface);

    [surface_rows, surface_cols] = size(surface_gray);

    aimer_mark = normxcorr2(aimer_gray, surface_gray);
    aimer_mark = im2bw(aimer_mark, 0.5);

    % consider using $ aimer_mark == 1 $ statement
    [aim_row, aim_col] = find(aimer_mark, 1);
    aim_row = round(aim_row - (aimer_rows/2));
    aim_col = round(aim_col - (aimer_cols/2));



    % dont forget you need to find the white ball only once!!! everytime user
    % hits the ball just find it and than stop ( faster )

    % enhance values and usages (whether it will be gray or binary) until you
    % find the right values for all examples
    wb_mark1 = im2bw(normxcorr2(im2uint8(im2bw(wb1, 0.52)), im2uint8(im2bw(surface, 0.9))), 0.4);
    wb_mark2 = im2bw(normxcorr2(im2uint8(im2bw(wb2, 0.4)), im2uint8(im2bw(surface, 0.9))), 0.3);
    %wb_mark3 = im2bw(normxcorr2(im2uint8(im2bw(wb1, 0.22)), im2uint8(im2bw(surface, 0.5))), 0.25);

    wb_mark4 = im2bw(normxcorr2(im2uint8(im2bw(wb4, 0.4)), im2uint8(im2bw(surface, 0.9))), 0.3);



    %wb_mark = (wb_mark1 & wb_mark2) | (wb_mark1 & wb_mark3) | (wb_mark2 & wb_mark3);
    %wb_mark = wb_mark1 & wb_mark2 & wb_mark3;

    wb_mark = wb_mark1 & wb_mark2 & wb_mark4;



    %imshow(wb_mark);





    [wb_row, wb_col] = find(wb_mark == 1);
    wbrs = size(wb_row); wbcs = size(wb_col);

    wb_row = round(sum(wb_row) / wbrs(1));
    wb_col = round(sum(wb_col) / wbcs(1));

    wb_row = round(wb_row - (ball_rows/2));
    wb_col = round(wb_col - (ball_cols/2));

    m = (aim_row - wb_row) / (aim_col - wb_col);

    aim_y = (m*aim_col + (aim_row - m*aim_col));
    wb_y = (m*wb_col + (aim_row - m*aim_col));



    xmin = min([aim_col , wb_col]);
    xmax = max([aim_col , wb_col]);
    ymin = min([aim_row , wb_row]);
    ymax = max([aim_row , wb_row]);

    guideline1 = ones((xmax-xmin + ymax-ymin), 2);
    x_big_y = xmax-xmin > ymax-ymin;

    if ~x_big_y

        for y= ymin:ymax
            x = round((y-aim_row+aim_col*m) /m);
            index = x_big_y*(x-xmin+1) + ~x_big_y*(y-ymin+1);
            guideline1(index, :) = [x,y];
        end
    else 
        for x= xmin:xmax
            y = round(m*(x-aim_col)+aim_row);
            index = x_big_y*(x-xmin+1) + ~x_big_y*(y-ymin+1);
            guideline1(index, :) = [x,y];
        end
    end

    for x= (aim_col-aim_rad):(aim_col+aim_rad)
        y = abs(round((aim_rad^2 - (x-aim_col)^2) ^.5 + aim_row));
        surface(y,x,:) = [255,0,0];
        surface((2*aim_row-y)+1,x,:) = [255,0,0];
    end

    for i= 1:(xmax-xmin + ymax-ymin)
        if guideline1(i,:) == [1,1]; break; end
        surface(guideline1(i,2), guideline1(i,1), :) = [255,0,0];
    end

    col_dom = wb_col > aim_col;
    row_dom = wb_row > aim_row;
    
    mid_pt = [aim_col, aim_row];
    for i= 1:10

        m = -m;

        skip = 0;

        guideline2 = ones(border(3)+border(4), 2);

        if ~x_big_y

            for y= border(1):border(3)
                x = round((y-mid_pt(2)+mid_pt(1)*(m)) /(m));
                if x < border(2) || x > border(4);
                    skip = skip + 1;
                    continue;
                end
                index = y-border(1)-skip+1;
                guideline2(index, :) = [x,y];
            end

        else

            for x= border(2):border(4)
                y = round((m)*(x-mid_pt(1))+mid_pt(2));
                if y < border(1) || y > border(3);
                    skip = skip + 1;
                    continue;
                end
                index = x-border(2)-skip+1;
                guideline2(index, :) = [x,y];
            end

        end


        if guideline2(1,1) < border(2) || guideline2(1,1) > border(4)
            break; end
        if guideline2(1,2) < border(1) || guideline2(1,2) > border(3)
            break; end

        if guideline2(index,1) < border(2) || guideline2(index,1) > border(4)
            break; end
        if guideline2(index,2) < border(1) || guideline2(index,2) > border(3)
            break; end

        for j= 1:(border(3)+border(4))
            if guideline2(j,:) == [1,1]
                lst_inx = j-1; break;
            end
            % draw line minus the radius !@
            surface(guideline2(j,2), guideline2(j,1), :) = [255,0,0];
        end
        
        
        
        
        
        
        % do self table of understanding the algorithm and solve the bugs
        % consider the row and col dominant
        
        
        
        
        
        
        if col_dom && mid_pt(1) <= border(2); col_dom = ~col_dom; end
        if row_dom && mid_pt(2) <= border(1); row_dom = ~row_dom; end
            
        if ~col_dom
            if m < 0; mid_pt = [guideline2(1,1), guideline2(1,2)];
            else mid_pt = [guideline2(lst_inx,1), guideline2(lst_inx,2)]; end
            
        else
            if m > 0; mid_pt = [guideline2(1,1), guideline2(1,2)];
          	else mid_pt = [guideline2(lst_inx,1), guideline2(lst_inx,2)]; end
        end
        
        if ~row_dom
            if m < 0; mid_pt = [guideline2(1,1), guideline2(1,2)];
            else mid_pt = [guideline2(lst_inx,1), guideline2(lst_inx,2)]; end
        else
            if m > 0; mid_pt = [guideline2(1,1), guideline2(1,2)];
          	else mid_pt = [guideline2(lst_inx,1), guideline2(lst_inx,2)]; end
        end
            
            
        
    end









    % get wb and ball gardient

    imtool(surface);


    %}

end

function [level] = hessian(filter_size, I)

    level = zeros(size(I,1), size(I,2));
    lobe_size = filter_size/3;
    for i = 2:size(I,1)
        for j = 2:size(I,2)
            %check loop parameters
            x = i - (filter_size-1)/2 - 1;
            y = j - (filter_size-1)/2 - 1;
            if(x < 1 ||y<1||x+filter_size>=size(I,1)||y+filter_size>=size(I,2))
                continue;
            end
            offset = (((filter_size/3)+1)/2);            
            
            dyy = I(x+lobe_size + 1, y+filter_size-offset + 1) - I(x+lobe_size+1, y+offset) - I(x, y+filter_size-offset + 1) + I(x, y+offset);
            x = x + lobe_size;
            
            dyy =dyy - 2*( I(x+lobe_size + 1, y+filter_size-offset + 1) - I(x+lobe_size+1, y+offset)- I(x, y+filter_size-offset + 1) + I(x, y+offset));
            x = x + lobe_size;
            
            dyy =dyy + I(x+lobe_size + 1, y+filter_size-offset + 1) - I(x+lobe_size+1, y+offset) - I(x, y+filter_size-offset + 1) + I(x, y+offset);
            x = i - (filter_size-1)/2 - 1;
            
            dxx = I(x + filter_size - offset + 1, y + lobe_size + 1) - I(x + offset, y + lobe_size + 1) - I(x + filter_size - offset + 1, y) + I(x + offset, y);
            y = y + lobe_size;
            
            dxx = dxx - 2*(I(x + filter_size - offset + 1, y + lobe_size + 1) - I(x + offset, y + lobe_size + 1) - I(x + filter_size - offset + 1, y) + I(x + offset, y));
            y = y + lobe_size;
            
            dxx = dxx + I(x + filter_size - offset + 1, y + lobe_size + 1) - I(x + offset, y + lobe_size + 1) - I(x + filter_size - offset + 1, y) + I(x + offset, y);
            %y = j - (filter_size-1)/2 - 1;
            base_x = x+offset-1;
            base_y = y+offset-1;
            dxy = 
            level(i,j) = (dxx*dyy) /(filter_size^4);%*dyy;
        end
    end
end
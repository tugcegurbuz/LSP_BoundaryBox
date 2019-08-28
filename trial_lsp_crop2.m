%%%This code finds the average distance of all connected parts then
%%%estimates a boundary box accordingly. At the end, it cuts images in
%%%different ratios of boundary box and saves them as a figure.

clc; clear; close('all');
%%Change directory to LSP and load joint annotations
cd 'C:\Users\klab\Desktop\LSP'
load('C:\Users\klab\Desktop\LSP\joints.mat')

%%Define numbers and joint labels
joint_labels = {'rankle', 'rknee', 'rhip', 'lhip', 'lknee', 'lankle',...
    'rwrist', 'relbow', 'rshoulder', 'lshoulder', 'lelbow', 'lwrist',...
    'neck', 'htop'};

%%Define connectedness map
map = {...
    {'rankle', 'rknee'}, {'rknee', 'rhip'}, {'rhip', 'rshoulder'},...
    {'lhip', 'lshoulder'},{'lknee', 'lhip'},{'lankle', 'lknee'},... 
    {'rwrist', 'relbow'},  {'relbow', 'rshoulder'}, {'rshoulder', 'neck'},...
    {'lshoulder', 'neck'}, {'lelbow', 'lshoulder'}, {'lwrist', 'lelbow'},...
    {'neck', 'htop'}...
     };

%%Create random sample of 100 images
inds = randi([1, 2000], 1, 50);

%%Define different boundary box ratios
bbox_ratios = [0.5, 0.8, 1];

%%Default padding value
padded = 0;

%%Go over each image
for im_ind = 1:length(inds)
    
    %Get image name
    im_num = inds(im_ind);
    im_id = sprintf('im%04d', im_num);
    im_name = sprintf('im%04d.jpg', im_num);
    
    
    %Get the image
    cd 'C:\Users\klab\Desktop\LSP'
    f = strcat('./images/', im_name);
    im = imread(f);
    
    %Get image size to decide the boundary box size
    [im_h, im_w, z] = size(im);

    %Go over each joint and find the distances
    joint_dists = [];
    
     for joint = 1:length(map)

        %Get main joint and its coordinates
        main_joint = joint_labels{joint};
        main_joint_coor = joints([2 1], joint, im_num);

        %Get neighboor joint and its coordinates
        nb_joint = map{joint}{2};
        nb_joint_ind = find(strcmp(joint_labels, nb_joint));
        nb_joint_coor = joints([2 1], nb_joint_ind, im_num);

        %Calculate the distance
        dist = sqrt(...
                    ((nb_joint_coor(1) - main_joint_coor(1)) ^ 2) +...
                    ((nb_joint_coor(2) - main_joint_coor(2)) ^ 2)...
                    );

        %Store the distances
        joint_dists = [joint_dists, dist];
     end
     
     %Calculate the average distance
     avg_dist = mean(joint_dists);
     
     %Go through each boundary box ratio
     for ratio_ind = 1:length(bbox_ratios)
        
        %Get the ratio
        ratio = bbox_ratios(ratio_ind);
        
        %Create figure to show each ratio
        fig = figure;
        title([num2str(ratio), '_', f]);
        
        %Go through each joint to crop
        for joint = 1:14
            
            %Get main joint and its coordinates
            main_joint = joint_labels{joint};
            main_joint_coor = joints([1 2], joint, im_num);
            
            %Calculate boundary box size based on average distance
            bbox_size = floor(avg_dist * ratio);
            half_bbox_size = floor(bbox_size / 2);
            
            %Find boundary box coordinates
            x1 = int32(main_joint_coor(1) - half_bbox_size);
            x2 = int32(main_joint_coor(1) + half_bbox_size);
            y1 = int32(main_joint_coor(2) - half_bbox_size);
            y2 = int32(main_joint_coor(2) + half_bbox_size);
            
            %Control whether boundary box size exceeds image dimensions
            if x1 <= 0
                %Do padding
                pad_w = abs(x1 + 1);
                if y1 <= 0
                    pad_h = abs(y1 + 1);
                    pad = zeros(pad_h, pad_w, 3);
                    im_part_wop = im(1:y2, 1:x2, :);
                    im_part = [pad, im_part_wop];
                    fprintf('x1 and y1 Padded im_num: %d', im_num)
                    padded = 1;
                elseif y2 > im_h
                    pad_h = abs(y2 - im_h + 1);
                    pad = zeros(pad_h, pad_w, 3);
                    im_part_wop = im(y1:im_h, 1:x2, :);
                    im_part = [pad, im_part_wop];
                    fprintf('x1 and y2 Padded im_num: %d', im_num)
                    padded = 1;
                else
                    pad_w = abs(x1 + 1);
                    pad = zeros(length(y1:y2), pad_w, 3);
                    im_part_wop = im(y1:y2, 1:x2, :);
                    im_part = [pad, im_part_wop];
                    fprintf('x1 Padded im_num: %d', im_num)
                    padded = 1;
                end
            elseif x2 > im_w
                %Do padding
                pad_w = abs(x2 - im_w + 1);
                if y1 <= 0
                    pad_h = abs(y1);
                    pad = zeros(pad_h, pad_w, 3);
                    im_part_wop = im(1:y2, x1:im_w, :);
                    im_part = [im_part_wop, pad];
                    fprintf('x2 and y1 Padded im_num: %d', im_num)
                    padded = 1;
                elseif y2 > im_h
                    pad_h = abs(y2 - im_h + 1);
                    pad = zeros(pad_h, pad_w, 3);
                    im_part_wop = im(y1:im_h, x1:im_w, :);
                    im_part = [im_part_wop, pad];
                    fprintf('x2 and y2 Padded im_num: %d', im_num)
                    padded = 1;
                else
                    pad = zeros(length(y1:y2), pad_w, 3);
                    im_part_wop = im(y1:y2, x1:im_w, :);
                    im_part = [im_part_wop, pad];
                    fprintf('x2 Padded im_num: %d', im_num)
                    padded = 1;
                end
            elseif y1 <= 0
                 %Do padding
                 pad_h = abs(y1 + 1);
                 pad = zeros(pad_h, length(x1:x2), 3);
                 im_part_wop = im(1:y2, x1:x2, :);
                 im_part = [pad; im_part_wop];
                 fprintf('y1 Padded im_num: %d', im_num)
                 padded = 1;
            elseif y2 > im_h
                 %Do padding
                 pad_h = abs(y2 - im_h + 1);
                 pad = zeros(pad_h, length(x1:x2), 3);
                 im_part_wop = im(y1:im_h, x1:x2, :);
                 im_part = [im_part_wop; pad];
                 fprintf('y2 Padded im_num: %d', im_num)
                 padded = 1;
            else
                %Crop normally
                im_part = im(y1:y2, x1:x2, :);
            end
            
            subplot(4, 4, joint)
            imshow(im_part)
            title(joint_labels(joint))
        end
        
        %Save bbox figure
        if padded
            fname_bbox = strcat('./padded/', im_id, '_', num2str(ratio), '.png');
            saveas(fig, fname_bbox);
        else
            fname_bbox = strcat('./figs_ratios/', im_id, '_', num2str(ratio), '.png');
            saveas(fig, fname_bbox);
        end
     end
end
 
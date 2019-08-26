clc; clear

%%Change directory to LSP and load joint annotations
cd 'C:\Users\klab\Desktop\LSP'
load('C:\Users\klab\Desktop\LSP\joints.mat')
mkdir('C:\Users\klab\Desktop\trial_cropped_lsp_ims')

%%Define numbers and joint labels
joint_labels = {'rankle', 'rknee', 'rhip', 'lhip', 'lknee', 'lankle',...
    'rwrist', 'relbow', 'rshoulder', 'lshoulder', 'lelbow', 'lwrist',...
    'neck', 'htop'};

%%Create 10 random indices to pick up images
inds = randi([1, 2000], 1, 3);

%%Define different boundary box ratios
bbox_ratios = [0.1 0.2 0.05, 0.03];

%%Go over each images and crop them
for im_ind = 1:length(inds)
    
    %Get image name
    im_num = inds(im_ind);
    im_id = sprintf('im%04d', im_num);
    im_name = sprintf('im%04d.jpg', im_num);
    
    %Get the image
    cd 'C:\Users\klab\Desktop\LSP'
    f = strcat('./images/', im_name);
    im = imread(f);
    
    %Get image size to decide the boundary box size (h/10)
    [im_h, im_w] = size(im);
    
    %Go through each boundary box ratio to cut images int different sizes
    for ratio_ind = 1:length(bbox_ratios)
        ratio = bbox_ratios(ratio_ind);
        bbox_size = floor(im_h * ratio);
        half_bbox_size = floor(bbox_size / 2);
        
        fig = figure;
        %Go through each joint (14) and crop them
        for joint = 1:14
            joint_center = joints([2 1], joint, im_num);
            
            %Add a control to mot to exceed image dimensions
            x1 = int32(joint_center(1) - half_bbox_size);
            x2 = int32(joint_center(1) + half_bbox_size);
            y1 = int32(joint_center(2) - half_bbox_size);
            y2 = int32(joint_center(2) + half_bbox_size);
            
            if x2 < im_h && (x1 * x2) >= 0 && (y1 * y2) >= 0 
                im_part = im(x1:x2, y1:y2, :);
                subplot(4, 4, joint)
                imshow(im_part)
                title(joint_labels(joint))
            else
                continue
            end
    
            %Save the joint images
            %fname = strcat(im_id, '_', num2str(ratio), '_', joint_labels{joint}, '.png')
            %full_file = strcat('C:\Users\klab\Desktop\trial_cropped_lsp_ims\', fname)
            %imwrite(im_part, full_file, 'png');
        end
        fname = strcat(im_id, '_', num2str(ratio), '.png')
        saveas(fig, fname)
    end
end
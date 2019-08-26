clc; clear

%%Change directory to LSP and load joint annotations
cd 'C:\Users\klab\Desktop\LSP'
load('C:\Users\klab\Desktop\LSP\joints.mat')
mkdir('C:\Users\klab\Desktop\cropped_lsp_ims')

%%Define numbers and joint labels
joint_labels = {'rankle', 'rknee', 'rhip', 'lhip', 'lknee', 'lankle',...
    'rwrist', 'relbow', 'rshoulder', 'lshoulder', 'lelbow', 'lwrist',...
    'neck', 'htop'};

%%Go over each images and crop them
for im_num = 1:2
    %Get image name
    im_id = sprintf('im%04d', im_num);
    im_name = sprintf('im%04d.jpg', im_num);
    im = imread(['./images/' im_name]);
    
    %Get image size to decide the boundary box size (h/10)
    im_h = size(im, 1);
    bbox_size = floor(im_h * 0.1);
    half_bbox_size = floor(bbox_size / 2);
    cd 'C:\Users\klab\Desktop\cropped_lsp_ims\'
    
    %Go through each joint (14) and crop them
    for joint = 1:14
        joint_center = joints([2 1], joint, im_num);
        im_part = im(...
            int32(joint_center(1) - half_bbox_size):...
            int32(joint_center(1) + half_bbox_size),...
            int32(joint_center(2) - half_bbox_size):...
            int32(joint_center(2) + half_bbox_size),...
            :...
        );
        %Save the joint images
        fname = strcat(im_id, '_', joint_labels{joint}, '.png')
        full_file = strcat('C:\Users\klab\Desktop\cropped_lsp_ims\', fname)
        imwrite(im_part, full_file, 'png');
    end
end
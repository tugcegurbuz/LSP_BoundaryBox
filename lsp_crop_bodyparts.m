%%%This code finds the average distance of all connected parts in a human 
%%%pose image. Then, it estimates a boundary box accordingly. 
%%%At the end, it cuts images and saves them.

clc; clear; close('all');
%%Change directory to LSP and load joint annotations
load('C:\Users\klab\Desktop\LSP_dataset\joints.mat')

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
%%Make data directory
mkdir('C:\Users\klab\Desktop\LSP_analyzed\data\')

%%Make direction of each data type and each joint
data_list = {'train', 'val', 'test'};

for list = 1:length(data_list)
    data_type = data_list{list};
    data_dir = strcat('C:\Users\klab\Desktop\LSP_analyzed\data\', data_type, '\');
    mkdir(data_dir)
    for l = 1:length(joint_labels)
        joint_name = joint_labels{l};
        label_dir = strcat(data_dir, joint_name, '\');
        mkdir(label_dir)
    end    
end

%%Create random sample for each data type

%Get 1000 training images
train_im_inds = randperm(2000, 1000);

%Get 500 training images
val_im_inds = [];
i = 1;
while i <= 500
    ind = randi([1, 2000], 1, 1);
    if sum(ismember(train_im_inds, ind)) == 0
        if sum(ismember(val_im_inds, ind)) == 0
            val_im_inds = [val_im_inds, ind];
            i = i + 1;
        end
    end
end

%Get 500 testing images
test_im_inds = [];
j = 1;
while j <= 500
    ind = randi([1, 2000], 1, 1);
    if sum(ismember(train_im_inds, ind)) == 0
        if sum(ismember(val_im_inds, ind)) == 0
            if sum(ismember(test_im_inds, ind)) == 0
                test_im_inds = [test_im_inds, ind];
                j = j + 1;
            end
        end
    end
end

%%Initialize a list for data type indices
data_type_inds = {train_im_inds, val_im_inds, test_im_inds};

%%Define different boundary box ratios
bbox_ratios = [1];

%%Default padding value
padded = false;


%%Go over each datatype
for data = 1:length(data_type_inds)
    inds = data_type_inds{data};
    
    %Go over each image
    for im_ind = 1:length(inds)

        %Get image name
        im_num = inds(im_ind);
        im_id = sprintf('im%04d', im_num);
        im_name = sprintf('im%04d.jpg', im_num);


        %Get the image
        f = strcat('C:\Users\klab\Desktop\LSP_dataset\images\', im_name);
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
                        pad = zeros(length(1:y2), pad_w, 3);
                        im_part_wop = im(1:y2, 1:x2, :);
                        im_part = [pad, im_part_wop];
                        fprintf('x1 and y1 Padded im_num: %d\n', im_num)
                        padded = true;
                    elseif y2 > im_h
                        pad_h = abs(y2 - im_h + 1);
                        pad = zeros(length(y1:im_h), pad_w, 3);
                        im_part_wop = im(y1:im_h, 1:x2, :);
                        im_part = [pad, im_part_wop];
                        fprintf('x1 and y2 Padded im_num: %d\n', im_num)
                        padded = true;
                    else
                        pad_w = abs(x1 + 1);
                        pad = zeros(length(y1:y2), pad_w, 3);
                        im_part_wop = im(y1:y2, 1:x2, :);
                        im_part = [pad, im_part_wop];
                        fprintf('x1 Padded im_num: %d\n', im_num)
                        padded = true;
                    end
                elseif x2 > im_w
                    %Do padding
                    pad_w = abs(x2 - im_w + 1);
                    if y1 <= 0
                        pad_h = abs(y1);
                        pad = zeros(length(1:y2), pad_w, 3);
                        im_part_wop = im(1:y2, x1:im_w, :);
                        im_part = [im_part_wop, pad];
                        fprintf('x2 and y1 Padded im_num: %d\n', im_num)
                        padded = true;
                    elseif y2 > im_h
                        pad_h = abs(y2 - im_h + 1);
                        pad = zeros(length(y1:im_h), pad_w, 3);
                        im_part_wop = im(y1:im_h, x1:im_w, :);
                        im_part = [im_part_wop, pad];
                        fprintf('x2 and y2 Padded im_num: %d\n', im_num)
                        padded = true;
                    else
                        pad = zeros(length(y1:y2), pad_w, 3);
                        im_part_wop = im(y1:y2, x1:im_w, :);
                        im_part = [im_part_wop, pad];
                        fprintf('x2 Padded im_num: %d\n', im_num)
                        padded = true;
                    end
                elseif y1 <= 0
                     %Do padding
                     pad_h = abs(y1 + 1);
                     pad = zeros(pad_h, length(x1:x2), 3);
                     im_part_wop = im(1:y2, x1:x2, :);
                     im_part = [pad; im_part_wop];
                     fprintf('y1 Padded im_num: %d\n', im_num)
                     padded = 1;
                elseif y2 > im_h
                     %Do padding
                     pad_h = abs(y2 - im_h + 1);
                     pad = zeros(pad_h, length(x1:x2), 3);
                     im_part_wop = im(y1:im_h, x1:x2, :);
                     im_part = [im_part_wop; pad];
                     fprintf('y2 Padded im_num: %d\n', im_num)
                     padded = true;
                else
                    %Crop normally
                    im_part = im(y1:y2, x1:x2, :);
                end
                
                if length(im_part) > 0
                    file_dir = strcat('C:\Users\klab\Desktop\LSP_analyzed\data\', data_list{data}, '\', main_joint, '\');
                    file_name = strcat(file_dir, im_id, '_', '.png');
                    imwrite(im_part, file_name, 'png');
                else
                    fprintf('Couldnt crop the image %d properly\n', im_num)
                end

            end
         end
    end
end
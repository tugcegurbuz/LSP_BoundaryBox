%%%This code finds the average distance of all connected parts and draws
%%%frequency distribution

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
inds = randi([1, 2000], 1, 2000);

%%Define different boundary box ratios
bbox_ratios = [0.5, 0.8, 1];

%%Default padding value
padded = 0;

%%Store average distances in a list
avg_dist_list = [];

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
     
     %Store average distances in variable for every image
     avg_dist_list = [avg_dist_list; avg_dist];
     
    
end

hist(avg_dist_list)
title('Average distance histogram')
xlabel('Average distance')
ylabel('Number of images')
 
%%%This code finds the distribution of average distance of each joint

clc; clear

%%Change directory to LSP and load joint annotations
cd 'C:\Users\klab\Desktop\LSP'
load('C:\Users\klab\Desktop\LSP\joints.mat')

%%Define numbers and joint labels
joint_labels = {'rankle', 'rknee', 'rhip', 'lhip', 'lknee', 'lankle',...
    'rwrist', 'relbow', 'rshoulder', 'lshoulder', 'lelbow', 'lwrist',...
    'neck', 'htop'};

%%Define connectedness map
map = {...
    {'rankle', 'rknee'}, {'rknee', 'rankle', 'rhip'}, {'rhip', 'rknee', 'rshoulder'},...
    {'lhip', 'lknee', 'lshoulder'},{'lknee', 'lankle', 'lhip'},{'lankle', 'lknee'},... 
    {'rwrist', 'relbow'},  {'relbow', 'rwrist', 'rshoulder'}, {'rshoulder', 'relbow'},...
    {'lshoulder', 'lelbow'}, {'lelbow', 'lwrist', 'lshoulder'}, {'lwrist', 'lelbow'},...
    {'neck', 'htop'}, {'htop', 'neck'}...
     };

%%Create random sample of 100 images
inds = randi([1, 2000], 1, 200);

%%Define different boundary box ratios
bbox_ratios = [0.5, 0.8, 1];

%%Define variables for each joint
joint_struct = {};

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
    
    %Get image size to decide the boundary box size
    [im_h, im_w] = size(im);
    
    %Go through each boundary box ratio to cut images int different sizes
    for ratio_ind = 1:length(bbox_ratios)
        
        %Get the ratio
        ratio = bbox_ratios(ratio_ind);
        
        %Create figure to show each ratio
        %fig = figure;
        %title([num2str(ratio), '_', f]);
        
        for joint = 1:14
            
            %Get main joint and its coordinates
            main_joint = joint_labels{joint};
            main_joint_coor = joints([2 1], joint, im_num);
            
            %Get neighboor joints and store their distances
            num_nb_joint = (length(map{joint}) - 1);
            nb_joint_dists = [];
            
            for i = 1:num_nb_joint
                nb_joint = map{joint}{i + 1};
                nb_joint_ind = find(strcmp(joint_labels, nb_joint));
                nb_joint_coor = joints([2 1], nb_joint_ind, im_num);
                
                %Calculate distance
                dist = sqrt(...
                    ((nb_joint_coor(1) - main_joint_coor(1)) ^ 2) +...
                    ((nb_joint_coor(2) - main_joint_coor(2)) ^ 2)...
                );
                nb_joint_dists = [nb_joint_dists, dist];
            end
            
            %Calculate average distance to neighboring joints
            avg_dist = mean(nb_joint_dists);
            
            %Store them with the main joint name
            joint_struct(im_ind).(main_joint) = avg_dist;
            
            %Calculate boundary box size based on average distance
            bbox_size = floor(avg_dist * ratio);
            half_bbox_size = floor(bbox_size / 2);
            
            %Add a control to mot to exceed image dimensions
            x1 = int32(main_joint_coor(1) - half_bbox_size);
            x2 = int32(main_joint_coor(1) + half_bbox_size);
            y1 = int32(main_joint_coor(2) - half_bbox_size);
            y2 = int32(main_joint_coor(2) + half_bbox_size);
            
            if y2 < im_h && (x1 * x2) >= 0 && (y1 * y2) >= 0 && x2 < im_h && x1 > 0 && y1 > 0
                im_part = im(x1:x2, y1:y2, :);
                %subplot(4, 4, joint)
                %imshow(im_part)
                %title(joint_labels(joint))
            else
                continue
            end
        end
        
        %Save bbox figure
        %fname_bbox = strcat(im_id, '_', num2str(ratio), '.png')
        %saveas(fig, fname_bbox)
    end
end

%%Show distribution of average distances for each joint

%Get list of fields
fields = fieldnames(joint_struct);

%Go through each field, and plot a histogram
for j = 1:length(fields)
    label = char(fields(j));
    dists = [joint_struct.(label)];
    d = sort(round(dists));
    
    fig2 = figure;
    hist(d)
    fname_hist = strcat(label, '_', '.png')
    saveas(fig2, fname_hist)
end

%Save the histogram
 
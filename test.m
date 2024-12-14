clc; clear; close all; 
Puzzle = "Q4\Q4\Puzzle_4_600_960\Unrotated_40\";
% Infomation = split(Puzzle,"\");
% model = split(Infomation(4),"_");

Output_Path = strcat(Puzzle,"Output.tif");
a=dir(strcat(Puzzle, 'Patch_*.tif'));
Num_pairs=size(a,1);
Output = im2double(imread(Output_Path));
Output_Size = size(Output);
Patch_Size = sqrt(Output_Size(1)*Output_Size(2)/(Num_pairs+4));

[filepath,name,ext] = fileparts(Output_Path);
Original = im2double(imread(strcat(Puzzle,"Original.tif")));
imshow(Original);
Corner1 = im2double(imread(strcat(Puzzle,"Corner_1_1.tif")));
Not_Match_Images = 1:Num_pairs;
D = zeros(1,Num_pairs)+300;

for K=0:(Output_Size(1)/Patch_Size)-3
    counter = 0;
%     Corner1 = rgb2gray(Corner1);
    LNeighber_LBP_feature = extractLBPFeatures(Corner1(:,:,1));
    for i=Not_Match_Images
        Pair_Name = strcat(Puzzle,sprintf("Patch_%d.tif", i));
        Pair = im2double(imread(Pair_Name));
%         Temp = rgb2gray(Pair);
        Pair_LBP_feature = extractLBPFeatures(Pair(:,:,1));

        t1 = LNeighber_LBP_feature;
        t2 = Pair_LBP_feature;
        D(i) = norm(t1-t2);
        counter = counter+1;
    end
    display(counter);
    [num,index] = min(D);
    Correct_Pair = strcat(Puzzle,sprintf("Patch_%d.tif", index));
    J = im2double(imread(Correct_Pair));
    Output(1+Patch_Size+K*Patch_Size:2*Patch_Size+K*Patch_Size,1:Patch_Size,:) = J;
    imshow(Output);
    Corner1 = J;
    Not_Match_Images = Not_Match_Images(Not_Match_Images~=index);
    D = zeros(1,Num_pairs)+300;
end
% K2=4:-1:0
for K2=(Output_Size(1)/Patch_Size)-1:-1:0
    Corner1 = Output(1+K2*Patch_Size:Patch_Size+K2*Patch_Size,1:Patch_Size,:);
    Num_Culomn = (Output_Size(2)/Patch_Size)-2;
    if K2 == 0 || K2 ==(Output_Size(1)/Patch_Size)-1
            Num_Culomn = Num_Culomn - 1;
    end
    for K=0:Num_Culomn
        for i=Not_Match_Images
            Pair_Name = strcat(Puzzle,sprintf("Patch_%d.tif", i));
            Pair = im2double(imread(Pair_Name));
            t1 = Corner1(:,Patch_Size);
            t2 = Pair(:,1);
            D(i) = norm(t1-t2);
           counter = counter+1;   
        end
        display(counter);
        [num,index] = min(D);
        Correct_Pair = strcat(Puzzle,sprintf("Patch_%d.tif", index));
        J = im2double(imread(Correct_Pair));
        Output(1+K2*Patch_Size:Patch_Size+K2*Patch_Size,1+Patch_Size+K*Patch_Size:2*Patch_Size+K*Patch_Size,:) = J;
        imshow(Output);
        Corner1 = J;
        Not_Match_Images = Not_Match_Images(Not_Match_Images~=index);
        D = zeros(1,Num_pairs)+300;
        counter = 0;

    end
end

%% part1
clc; clear; close all; 
% Puzzle = "Q4\Q4\Puzzle_1_1200_1920\R_U_40\"; 
Puzzle = "Q4\Q4\Puzzle_1_1200_1920\Rotated_160\";
% Infomation = split(Puzzle,"\");
% model = split(Infomation(4),"_");
Delete_Matched_Pairs = true;

Output_Path = strcat(Puzzle,"Output.tif");
a=dir(strcat(Puzzle, 'Patch_*.tif'));
Num_pairs=size(a,1);
Output = im2double(imread(Output_Path));
Output_Size = size(Output);
Patch_Size = sqrt(Output_Size(1)*Output_Size(2)/(Num_pairs+4));

% [filepath,name,ext] = fileparts(Output_Path);
Original = im2double(imread(strcat(Puzzle,"Original.tif")));
% imshow(Original);
% Corner1 = im2double(imread(strcat(Puzzle,"Corner_1_1.tif")));
Corner1 = Output(1:Patch_Size,1:Patch_Size,:);
Not_Match_Images = 1:Num_pairs;
Is_Rotated = contains(Puzzle,"Rotated");
Corner1_HOG_Feature = extractHOGFeatures(Corner1);
colorBag = exampleBagOfFeaturesColorExtractor(Corner1);

minimums = zeros(Num_pairs,1)+300;
number_of_matched_patchs = 0;
% rotate pairs..............................
if Is_Rotated
    destdirectory = strcat("Q4\Q4\Puzzle_1_1200_1920\",sprintf("R_U_%d",(Num_pairs+4)));
    mkdir(destdirectory);   %create the directory 
%   copyfile(Puzzle, destdirectory)
    Old_Puzzle = Puzzle;
    Puzzle = strcat(destdirectory,"\");
    Num_New_pairs = 0;
    for i=Not_Match_Images
        Pair_Name = strcat(Old_Puzzle,sprintf("Patch_%d.tif", i));
        Pair = (imread(Pair_Name));
%         imshow(Pair);
        counter = 0;
        for j=0:90:270
            Rotated = imrotate(Pair,j);
%             imshow(Rotated);
            Name = strcat(Puzzle,sprintf("Patch_%d.tif", counter+i+Num_New_pairs));
            imwrite(Rotated,Name);
            counter = counter+1;
        end
        Num_New_pairs = Num_New_pairs+3;
    end
    a=dir(strcat(Puzzle, 'Patch_*.tif'));
    Num_pairs=size(a,1);
    Not_Match_Images = 1:Num_pairs;
end


D = zeros(1,Num_pairs)+300;
for K=0:(Output_Size(1)/Patch_Size)-3
    counter = 0;
    for i=Not_Match_Images
        Pair_Name = strcat(Puzzle,sprintf("Patch_%d.tif", i));
        Pair = im2double(imread(Pair_Name));
        t1 = Corner1(Patch_Size,:);
        t2 = Pair(1,:);
        D(i) = norm(t1-t2);
        counter = counter+1;
    end
    display(counter);
    [num,index] = min(D);
    number_of_matched_patchs = number_of_matched_patchs+1;
    minimums(number_of_matched_patchs) = num;

    Correct_Pair = strcat(Puzzle,sprintf("Patch_%d.tif", index));
    J = im2double(imread(Correct_Pair));
    Output(1+Patch_Size+K*Patch_Size:2*Patch_Size+K*Patch_Size,1:Patch_Size,:) = J;
    imshow(Output);
    Corner1 = J;
    Corner1_HOG_Feature = extractHOGFeatures(Corner1);
    % delete pairt after finding it
    if Delete_Matched_Pairs
        if Is_Rotated
            rem1 = rem(index,4);
            if rem1 == 0
                rem1 = 4;
            end
            index = index - rem1;
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+1);
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+2);
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+3);
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+4);
        else
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index);
        end
    end
    %...............................
    %
%     Not_Match_Images = Not_Match_Images(Not_Match_Images~=index);
    D = zeros(1,Num_pairs)+300;
end

for K2=0:0
    Corner1 = Output(1+K2*Patch_Size:Patch_Size+K2*Patch_Size,1:Patch_Size,:);
    Corner1_HOG_Feature = extractHOGFeatures(Corner1);
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
        number_of_matched_patchs = number_of_matched_patchs+1;
        minimums(number_of_matched_patchs) = num;   
        Correct_Pair = strcat(Puzzle,sprintf("Patch_%d.tif", index));
        J = im2double(imread(Correct_Pair));
        Output(1+K2*Patch_Size:Patch_Size+K2*Patch_Size,1+Patch_Size+K*Patch_Size:2*Patch_Size+K*Patch_Size,:) = J;
        imshow(Output);
        Corner1 = J;
        Corner1_HOG_Feature = extractHOGFeatures(Corner1);
    % delete pairt after matching it
    if Delete_Matched_Pairs
        if Is_Rotated
            rem1 = rem(index,4);
            if rem1 == 0
                rem1 = 4;
            end
            index = index - rem1;
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+1);
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+2);
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+3);
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+4);
        else
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index);
        end
    end
    %...............................
            D = zeros(1,Num_pairs)+300;
        counter = 0;

    end
end


D2 = zeros(1,Num_pairs)+300;
D_Norm2 = zeros(1,Num_pairs)+300;

% K2=1:(Output_Size(1)/Patch_Size)-1
% K2=(Output_Size(1)/Patch_Size)-1:-1:1
%......NORM2    
for K2=1:(Output_Size(1)/Patch_Size)-1
    Corner1 = Output(1+K2*Patch_Size:Patch_Size+K2*Patch_Size,1:Patch_Size,:);
    Corner1_HOG_Feature = extractHOGFeatures(Corner1);
    Top_Pair = Output(1+(K2-1)*Patch_Size:Patch_Size+(K2-1)*Patch_Size,1+Patch_Size:2*Patch_Size,:);
%     imtool(Corner1);
%     imtool(Top_Pair);
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
            j1 = Top_Pair(Patch_Size,:);
            j2 = Pair(1,:);
            D(i) = norm(t1-t2);
            D2(i) = norm(j1-j2);
            D_Norm2(i) = sqrt(D2(i)^2+D(i)^2);
%             D_Norm2(i) = (D2(i)+D(i))/2;
%             D_Norm2(i) = norm(D2(i)-D(i));
            counter = counter+1;   
        end
        display(counter);
        [num,index] = min(D_Norm2);
        number_of_matched_patchs = number_of_matched_patchs+1;
        minimums(number_of_matched_patchs) = num;
        Correct_Pair = strcat(Puzzle,sprintf("Patch_%d.tif", index));
        J = im2double(imread(Correct_Pair));
        Output(1+K2*Patch_Size:Patch_Size+K2*Patch_Size,1+Patch_Size+K*Patch_Size:2*Patch_Size+K*Patch_Size,:) = J;
        imshow(Output);
        Corner1 = J;
        Corner1_HOG_Feature = extractHOGFeatures(Corner1);
        if K ~= Num_Culomn
        Top_Pair = Output(1+(K2-1)*Patch_Size:Patch_Size+(K2-1)*Patch_Size,1+Patch_Size+(K+1)*Patch_Size:2*Patch_Size+(K+1)*Patch_Size,:);
        end
%         imtool(Corner1);
%         imtool(Top_Pair);
%         pause;
    % dlete pairt after finding it
    if Delete_Matched_Pairs
        if Is_Rotated
            rem1 = rem(index,4);
            if rem1 == 0
                rem1 = 4;
            end
            index = index - rem1;
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+1);
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+2);
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+3);
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index+4);
        else
            Not_Match_Images = Not_Match_Images(Not_Match_Images~=index);
        end
    end
    %...............................
    D = zeros(1,Num_pairs)+300;
    D2 = zeros(1,Num_pairs)+300;
    D_Norm2 = zeros(1,Num_pairs)+300;
    counter = 0;

    end
end

if Is_Rotated
    rmdir(destdirectory,"s");   
end


%% part 2
clc; clear; close all; 
% Puzzle = "Q4\Q4\Puzzle_1_1200_1920\R_U_40\";
Puzzle = "Q4\Q4\Puzzle_1_1200_1920\Unrotated_160\";
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
% imshow(Original);
Corner1 = im2double(imread(strcat(Puzzle,"Corner_1_1.tif")));
Not_Match_Images = 1:Num_pairs;
Is_Rotated = contains(Puzzle,"Unrotated");
if Is_Rotated
    destdirectory = strcat("Q4\Q4\Puzzle_1_1200_1920\",sprintf("R_U_%d",(Num_pairs+4)));
    mkdir(destdirectory);   %create the directory 
    copyfile(Puzzle, destdirectory)
    Puzzle = strcat(destdirectory,"\");

    for i=Not_Match_Images
        Pair_Name = strcat(Puzzle,sprintf("Patch_%d.tif", i));
        Pair = (imread(Pair_Name));
        imshow(Pair);
        counter = 0;
        for j=90:90:270
            Rotated = imrotate(Pair,j);
            imshow(Rotated);
            Name = strcat(Puzzle,sprintf("Patch_%d.tif", counter+i+Num_pairs));
            imwrite(Rotated,Name);
            counter = counter+1;
        end
        Num_pairs = Num_pairs+2;
    end
    a=dir(strcat(Puzzle, 'Patch_*.tif'));
    Num_pairs=size(a,1);
    Not_Match_Images = 1:Num_pairs;
end


D = zeros(1,Num_pairs)+300;
for K=0:(Output_Size(1)/Patch_Size)-3
    counter = 0;
    for i=Not_Match_Images
        Pair_Name = strcat(Puzzle,sprintf("Patch_%d.tif", i));
        Pair = im2double(imread(Pair_Name));
        t1 = Corner1(Patch_Size,:);
        t2 = Pair(1,:);
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
for K2=0:(Output_Size(1)/Patch_Size)-1
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
if Is_Rotated
    rmdir(destdirectory,"s");   
end% GS = rgb2gray(Output);
% Edges = edge(GS);
% imshow(Edges);
% I = rgb2gray(I);
% S = imfilter(I,fspecial('average',[51 51]));
% K = 0.8;
% T = K*S;
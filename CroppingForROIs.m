%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%               CroppingForROIs - Creates regions from a raw data file 
%                                                         
%                       Ruby Peters, King's College London, 2016.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% User inputs

%Input: Raw data can take .txt or .csv extensions but x data in column 1
%and y data in column 2. 

MainDirectory = 'C:\Users\Ruby\Desktop\Kate\011216\Cell 2\';  %Please enter your main directory. 

Array_of_centres_for_CROP=[0.85 1.3;0.8 0.85;1.1 0.9; 1.15 1.25]*1e4;         %Please enter the co-ordinates of the center of each 
                                   ... ROI you would like to crop in the form : [x1 y1; x2 y2; x3 y3] 

Size_ROI=3000;                        %Please enter your desired size of ROI
                                   ...in nm. Default for experimental data = 3x3um. 

%%

FolderName = input('Folder name\n','s');
FileName = input('File name with extension\n','s');
Path = [MainDirectory,FolderName,'\',FileName];
data=load(Path);

number_of_ROIS=size(Array_of_centres_for_CROP,1);

for i=1:number_of_ROIS
    
cd(MainDirectory);
xc=Array_of_centres_for_CROP(i,1);
yc=Array_of_centres_for_CROP(i,2);

xrow = find((data(:,1) >= xc-(Size_ROI/2)) & (data(:,1) <= xc+(Size_ROI/2)));
output =  data(xrow,:);

yrow=find((output(:,2) >= yc-(Size_ROI/2)) & (output(:,2) <=yc+(Size_ROI/2)));
datacrop= output(yrow,:);

mkdir(['Region', num2str(i)]);
cd(['Region', num2str(i)]);
dlmwrite(['Region', num2str(i), '_crop.txt'], datacrop)

CentreRegion=[xc, yc]; 
FileName2=['CentreRegion', num2str(i),'.txt'];
dlmwrite(FileName2, CentreRegion)

end

cd(MainDirectory)
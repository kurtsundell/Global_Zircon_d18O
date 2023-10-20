% Supporting code for Sundell et al (submitted, Geology) for bivariate KDE of global d18O data

clear all
close all
clc

[filename pathname] = uigetfile({'*'},'File Selector'); %load the supplemental file with zircon age eHfT data

if ispc == 1
	fullpathname = char(strcat(pathname, '\', filename));
end
if ismac == 1
	fullpathname = char(strcat(pathname, '/', filename));
end

% Range of 2D data
xmin = 0;
xmax = 1000;
ymin = -30;
ymax = 15;
extra = 0;

% kernel bandwidths
bandwidth_x = 10;
bandwidth_y = .25;

% how many pixels for the images, has to be in powers of 2, no need to go over go over 2^12, results look the same
gridspc = 2^9;

% Read in data, format is name header and two columns of info, for our example we use age + Hf, but any 2D data will work
[numbers text, data] = xlsread(fullpathname);
numbers = num2cell(numbers);

% Filter out any data that are not pairs of numbers
for i = 1:size(numbers,1)
	for j = 1:size(numbers,2)
		if cellfun('isempty', numbers(i,j)) == 0
			if cellfun(@isnan, numbers(i,j)) == 1
				numbers(i,j) = {[]};
			end
		end
	end
end

% pull the names from the headers
for i = 1:(size(data,2)+1)/2
	Name(i,1) = data(1,i*2-1);
end

data_tmp = numbers(1:end,:); %use temporary variable
N = size(data_tmp,2)/2; % figure out how many samples

% Filter out any data not in the range set above
for k = 1:N
	for i = 1:length(data_tmp(:,1))
		if cellfun('isempty', data_tmp(i,k*2-1)) == 0 && cellfun('isempty', data_tmp(i,k*2)) == 0
			if cell2num(data_tmp(i,k*2-1)) >= xmin && cell2num(data_tmp(i,k*2-1)) <= xmax && ...
					cell2num(data_tmp(i,k*2)) >= ymin && cell2num(data_tmp(i,k*2)) <= ymax
				data1(i,k*2-1:k*2) = cell2num(data_tmp(i,k*2-1:k*2));
			end
		end
	end
end

% set min/max ranges for kde2d function
MIN_XY=[xmin-extra,ymin];
MAX_XY=[xmax+extra,ymax];

%colormap
cmap = cmocean('balance',300);
cmap(1:3,:) = 1; %clip zero vals at 95% and set as white space

wind = 200;

% Make and plot bivariate kdes for samples, save as 3D matrix block
for k = 1:N
	data2 = data1(:,k*2-1:k*2);
	data2 = data2(any(data2 ~= 0,2),:);
	if isempty(data2) == 0
		if length(data2(:,1)) > 10
			
			[bandwidth1,density1(:,:,k),X1,Y1] = kde2d_set_kernel(data2, gridspc, MIN_XY, MAX_XY, bandwidth_x, bandwidth_y);
			density1(:,:,k) = density1(:,:,k)./sum(sum(density1(:,:,k)));
			
			figure
			hold on
			
			%plot density
 			surf(X1,Y1,density1(:,:,k));
			
			%make contours
			max_density1 = max(max(density1(:,:,k)));
			perc = 0.99; % percent of bivariate KDE from peak
			max_density_conf(k,1) = max_density1*(1-perc); % contour at 68% from peak density
			
			%F1 = figure;
			%plot contours
			%contour3(X1,Y1,density1(:,:,k),[max_density_conf(k,1) max_density_conf(k,1)],'k', 'LineWidth', 3);
			%[file,path] = uiputfile('*.eps','Save file'); print(F1,'-depsc','-painters',[path file]); epsclean([path file]); % save simplified contours

			% format plots
			colormap(cmap)
			shading interp
			view(2)
 			title(Name(k,1),'FontSize',40, 'interpreter', 'none')
			xlabel('Age (Ma)','FontSize',20)
			ylabel('Zircon d18O','FontSize',20)
 			axis([xmin-extra xmax+extra 0 14])
			set(gca,'FontSize',20)


			
			hold on
			X2 = (data2(:,1));
			Y2 = (data2(:,2));
			[X_sorted, X_order] = sort(X2);
			Y_sorted = Y2(X_order,:);
			M2 = movmedian(Y_sorted,wind);
			plot3(X_sorted,M2,ones(length(M2),1), 'linewidth',3, 'color', 'g')
			plot3([0,1000],[5.3,5.3],[1,1],'k')
			%plot([0,1000],[5.9,5.9],'k')
			%plot([0,1000],[4.7,4.7],'k')
			axis([xmin-extra xmax+extra 0 14])
			
		end
	end
	
	clear data2 M M2 Std
	%[file,path] = uiputfile('*.eps','Save file'); print(F1,'-depsc','-painters',[path file]); epsclean([path file]); % save simplified contours
	
end
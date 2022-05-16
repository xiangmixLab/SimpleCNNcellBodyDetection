function dpc_res=density_peak_clustering(imgd,radius)

imgd=double(imgd);

imgd_pad=padarray(imgd,[radius+1 radius+1],'both');
dpc_res=imgd_pad*0;

imgd_pad_high=(imgd_pad>10);
imgd_pad_high=bwareaopen(imgd_pad_high,64);
[imgd_high_coor(:,1),imgd_high_coor(:,2)]=find(imgd_pad_high>0);

dis2cen_mat=[];
for u=-radius:radius
    for v=-radius:radius
        dis2cen=((u-size(imgd,1)/2)^2+(v-size(imgd,2)/2)^2)^0.5;
        dis2cen_mat(u+radius+1,v+radius+1)=dis2cen;
    end
end

% tic;
for k=1:size(imgd_high_coor,1)
    i=imgd_high_coor(k,1);
    j=imgd_high_coor(k,2);
    if imgd_pad(i,j)>0
        dpc_res_t=sum(sum(imgd_pad(i-radius:i+radius,j-radius:j+radius).*(1/((2*pi)^0.5*radius)).*exp(-dis2cen_mat.^2./(2*radius^2))));
        dpc_res(i,j)=dpc_res_t;
    end
end
% toc;
dpc_res=dpc_res(radius+2:size(dpc_res,1)-radius-1,radius+2:size(dpc_res,2)-radius-1);
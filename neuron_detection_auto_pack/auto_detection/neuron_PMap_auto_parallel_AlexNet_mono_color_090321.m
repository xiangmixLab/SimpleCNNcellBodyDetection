function [score_result]=neuron_PMap_auto_parallel_AlexNet_mono_color_090321(net,net1,img,major_slice_area,patch_size)

    %% resize to speed up (no...)
    imgr=img;
    patch_size_r=patch_size;

    %% determine processing pixel idx
    disp('determining process range...');
    detect_range=[];
    [detect_range(:,1),detect_range(:,2)]=find(major_slice_area==1);
    detect_range(detect_range(:,1)<=patch_size(2)/2,:)=[];
    detect_range(detect_range(:,1)>=(size(major_slice_area,1)-patch_size(2)/2)-1,:)=[];
    detect_range(detect_range(:,2)<=patch_size(2)/2,:)=[];
    detect_range(detect_range(:,2)>=(size(major_slice_area,2)-patch_size(2)/2)-1,:)=[];
    
    for i=1:size(detect_range,1)
        intensity_pix(i,1)=imgr(detect_range(i,1),detect_range(i,2),1);
    end
    
    idx_further_del=intensity_pix<30;
    detect_range(idx_further_del,:)=[];
    
    clear intensity_pix
    disp('complete')

    %% classifing patches
    disp('processing patches...please wait...');

    % part 1: classical detection
    tic;
    pix_list_length=size(detect_range,1);
    patch_t_all=zeros(patch_size(1),patch_size(2),3,pix_list_length);
    for k=1:pix_list_length
        i=detect_range(k,1);
        j=detect_range(k,2);
        patch_t=imgr(i-floor(patch_size_r(2)/2):i+ceil(patch_size_r(2)/2)-1,j-floor(patch_size_r(1)/2):j+ceil(patch_size_r(1)/2)-1,:);
%         patch_t=imresize(patch_t,[36,36]);
        patch_t1=squeeze(double(patch_t(:,:,1)));
        patch_t1=zscore(patch_t1);
        patch_t1(patch_t1<=0)=0;
        patch_t1=patch_t1/max(patch_t1(:));
        patch_t_all(:,:,1,k)=patch_t1;
        toc;
    end 
    
    if ~isempty(patch_t_all)
        [~,score]=classify(net,patch_t_all);
        score_result_t=score(:,2);
    else
        score_result_t=[];
    end
        
    patch_t_all1=squeeze(patch_t_all(:,:,1,:));
    patch_t_all1=patch_t_all1(:,:,score_result_t>quantile(score_result_t,0.1));
    detect_range1=detect_range(score_result_t>quantile(score_result_t,0.1),:);
    toc;
    
    disp(['complete part 1']);
    
    % part 2: geometry detection
    
    %% conclusion
    
    if ~isempty(score_result_t)
        score_result=double(imgr(:,:,1)*0);
        for i=1:size(detect_range1,1)
            score_result(detect_range1(i,1),detect_range1(i,2))=score_result_t(i);
        end
    else
        score_result=double(imgr(:,:,1)*0);
    end

    se=strel('disk',15);
    score_result=imdilate(score_result,se);
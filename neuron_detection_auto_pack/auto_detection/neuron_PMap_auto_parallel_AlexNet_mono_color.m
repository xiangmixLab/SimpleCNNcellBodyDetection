function [score_result]=neuron_PMap_auto_parallel_AlexNet_mono_color(net,img,patch_size)

    %% resize to speed up (no...)
    imgr=img;
    patch_size_r=patch_size;
    %% determine possible neuron area range
    img1=squeeze(imgr(:,:,1)-imgr(:,:,2));

    img1_threst1=img1>1;
    img1_threst1=imfill(img1_threst1,'holes');
    img1_threst1=bwareaopen(img1_threst1,1000000);
    se=strel('disk',10);
    img1_threst1=imopen(img1_threst1,se);
    img1_threst=img1.*uint8(img1_threst1);
    for i=2:50
        img1_threst=img1>i;
        ratio=sum(img1_threst(:))/(size(img1,1)*size(img1,2));
        if ratio<0.0001
            img1_threst=img1>i;
            break;
        end
    end
    
    disp(['threshold is ',num2str(i)]);
    img1_threst=bwareaopen(img1_threst,25);

    img1_thres=img1_threst*0;
    img1_thres(1:2:end,1:2:end)=img1_threst(1:2:end,1:2:end);
    %% determine processing pixel idx
    disp('determining process range...');
    detect_range=[];
    [detect_range(:,1),detect_range(:,2)]=find(img1_thres>0);
    detect_range(detect_range(:,1)<(floor(patch_size_r(1))+1),:)=[];
    detect_range(detect_range(:,1)>(size(img1,1)-floor(patch_size_r(1))-1),:)=[];
    detect_range(detect_range(:,2)<(floor(patch_size_r(2))+1),:)=[];
    detect_range(detect_range(:,2)>(size(img1,2)-floor(patch_size_r(2))-1),:)=[];

    disp('complete')

    %% classifing patches
    disp('processing patches...please wait...');

    tic;
    pix_list_length=size(detect_range,1);
    patch_t_all=zeros(patch_size(1),patch_size(2),1,pix_list_length);
    for k=1:pix_list_length
        i=detect_range(k,1);
        j=detect_range(k,2);
        patch_t=imgr(i-floor(patch_size_r(2)/2):i+ceil(patch_size_r(2)/2)-1,j-floor(patch_size_r(1)/2):j+ceil(patch_size_r(1)/2)-1,:);
%         patch_t=imresize(patch_t,[36,36]);
        patch_t1=patch_t(:,:,1);
        patch_t1=imadjust(patch_t1);
        patch_t1=imgaussfilt(patch_t1,0.5);
        patch_t_all(:,:,:,k)=patch_t1;
    end 
    
    if ~isempty(patch_t_all)
        [~,score]=classify(net,patch_t_all);
        score_result_t=score(:,2);
    else
        score_result_t=[];
    end
    
    toc;
    
    disp(['complete']);

    if ~isempty(score_result_t)
        score_result=double(imgr(:,:,1)*0);
        for i=1:size(detect_range,1)
            score_result(detect_range(i,1),detect_range(i,2))=score_result_t(i);
        end
    else
        score_result=double(imgr(:,:,1)*0);
    end

    se=strel('disk',2);
    score_result=imclose(score_result,se);
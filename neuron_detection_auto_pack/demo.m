fname={

    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_dSUB_20211123_01.vsi.Collection\Layer6\Layer.tif'		
    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_dSUB_20211123_01.vsi.Collection\Layer6\Layer.tif'		
    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_dSUB_20211123_01.vsi.Collection\Layer6\Layer.tif'		

    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_dSUB_20211123_01.vsi.Collection\Layer7\Layer.tif'	
    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_dSUB_20211123_01.vsi.Collection\Layer8\Layer.tif'		
    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_dSUB_20211123_01.vsi.Collection\Layer9\Layer.tif'		

    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_lowexposure_20211123_01.vsi.Collection\Layer6\Layer.tif'
    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_lowexposure_20211123_01.vsi.Collection\Layer6\Layer.tif'
    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_lowexposure_20211123_01.vsi.Collection\Layer6\Layer.tif'
    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_lowexposure_20211123_01.vsi.Collection\Layer7\Layer.tif'	
    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_lowexposure_20211123_01.vsi.Collection\Layer8\Layer.tif'		
    'D:\113021_Ginny_detection\C57_R0L1_SADdG-2xnls-tdtomato_lowexposure_20211123_01.vsi.Collection\Layer9\Layer.tif'		
	
}

savDir={

    'D:\022222_ginny_detection_additional\detection_res_2x\Layer6_1_high';
    'D:\022222_ginny_detection_additional\detection_res_2x\Layer6_2_high';
    'D:\022222_ginny_detection_additional\detection_res_2x\Layer6_3_high';
    'D:\022222_ginny_detection_additional\detection_res_2x\Layer7_high';
    'D:\022222_ginny_detection_additional\detection_res_2x\Layer8_high';
    'D:\022222_ginny_detection_additional\detection_res_2x\Layer9_high';

    'D:\022222_ginny_detection_additional\detection_res_2x\Layer6_1_low';
    'D:\022222_ginny_detection_additional\detection_res_2x\Layer6_2_low';
    'D:\022222_ginny_detection_additional\detection_res_2x\Layer6_3_low';
    'D:\022222_ginny_detection_additional\detection_res_2x\Layer7_low';
    'D:\022222_ginny_detection_additional\detection_res_2x\Layer8_low';
    'D:\022222_ginny_detection_additional\detection_res_2x\Layer9_low';    
    }

pos={
    [1895,4207,700,700];
    [1783,4907,700,700];
    [1995,5821,700,700];
    [1792,10027,700,700];
    [2688,12981,700,700];
    [1100,10560,1060,1060];   
    
     [1895,4207,700,700];
    [1783,4907,700,700];
    [1995,5821,700,700];
    [1792,10027,700,700];
    [2688,12981,700,700];
    [1100,10560,1060,1060];   
    }

% patch generation
patchDir={};
for i=1:size(savDir,1)
    for j=1:size(savDir,2)
        mkdir(savDir{i,j});
        img=imread(fname{i,j});
        patch=squeeze(img(pos{i,j}(2):pos{i,j}(2)+pos{i,j}(4),pos{i,j}(1):pos{i,j}(1)+pos{i,j}(3),:));

         patch=imrotate(patch,-90);
         patch=padarray(patch,[40,40],'both');
        imwrite(patch,[savDir{i,j},'\','patch.tif']);
        patchDir{i,j}=[savDir{i,j},'\','patch.tif'];
    end
end

net1Path='D:\031622_ginny_autodetection_latest_method\neuron_detection_auto_pack\trained_network\CNN_net_090721.mat'

% detection
for i=1:length(savDir)
    mkdir(savDir{i});
    [pts,res_loc]=detectPipeline_100721({patchDir{i,1}},-90,savDir{i},1,net1Path);
end
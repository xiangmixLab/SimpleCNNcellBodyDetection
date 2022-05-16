patchDir={'.\detection_res_2x\Layer6_1_high\patch.tif';'.\detection_res_2x\Layer6_2_high\patch.tif';'.\detection_res_2x\Layer6_3_high\patch.tif';'.\detection_res_2x\Layer7_high\patch.tif';'.\detection_res_2x\Layer8_high\patch.tif';'.\detection_res_2x\Layer9_high\patch.tif';'.\detection_res_2x\Layer6_1_low\patch.tif';'.\detection_res_2x\Layer6_2_low\patch.tif';'.\detection_res_2x\Layer6_3_low\patch.tif';'.\detection_res_2x\Layer7_low\patch.tif';'.\detection_res_2x\Layer8_low\patch.tif';'.\detection_res_2x\Layer9_low\patch.tif'};

savDir={

    '.\detection_res_2x\Layer6_1_high';
    '.\detection_res_2x\Layer6_2_high';
    '.\detection_res_2x\Layer6_3_high';
    '.\detection_res_2x\Layer7_high';
    '.\detection_res_2x\Layer8_high';
    '.\detection_res_2x\Layer9_high';

    '.\detection_res_2x\Layer6_1_low';
    '.\detection_res_2x\Layer6_2_low';
    '.\detection_res_2x\Layer6_3_low';
    '.\detection_res_2x\Layer7_low';
    '.\detection_res_2x\Layer8_low';
    '.\detection_res_2x\Layer9_low';    
    }

net1Path='.\trained_network\CNN_net_090721.mat'

% detection
for i=1:length(savDir)
    mkdir(savDir{i});
    [pts,res_loc]=detectPipeline_100721({patchDir{i,1}},-90,savDir{i},1,net1Path);
end
load -mat child_mind_spec.mat
gender    = cellfun(@(x)x(1), YOri);

%%
figure; 
scalpGender0 = mean(XOriSpec(:,:,:,gender==0),4);
scalpGender1 = mean(XOriSpec(:,:,:,gender==1),4);

min0_1 = nanmin(nanmin(scalpGender0(:,:,1)));
min0_2 = nanmin(nanmin(scalpGender0(:,:,2)));
min0_3 = nanmin(nanmin(scalpGender0(:,:,3)));
max0_1 = nanmax(nanmax(scalpGender0(:,:,1)));
max0_2 = nanmax(nanmax(scalpGender0(:,:,2)));
max0_3 = nanmax(nanmax(scalpGender0(:,:,3)));
scalpGender0(:,:,1) = (scalpGender0(:,:,1)-min0_1)/(max0_1-min0_1);
scalpGender0(:,:,2) = (scalpGender0(:,:,2)-min0_2)/(max0_2-min0_2);
scalpGender0(:,:,3) = (scalpGender0(:,:,3)-min0_3)/(max0_3-min0_3);
scalpGender0(isnan(scalpGender0(:))) = 0;

min0_1 = min(min(scalpGender1(:,:,1)));
min0_2 = min(min(scalpGender1(:,:,2)));
min0_3 = min(min(scalpGender1(:,:,3)));
max0_1 = max(max(scalpGender1(:,:,1)));
max0_2 = max(max(scalpGender1(:,:,2)));
max0_3 = max(max(scalpGender1(:,:,3)));
scalpGender1(:,:,1) = (scalpGender1(:,:,1)-min0_1)/(max0_1-min0_1);
scalpGender1(:,:,2) = (scalpGender1(:,:,2)-min0_2)/(max0_2-min0_2);
scalpGender1(:,:,3) = (scalpGender1(:,:,3)-min0_3)/(max0_3-min0_3);
scalpGender1(isnan(scalpGender1(:))) = 0;

subplot(1,2,1); imagesc(1-scalpGender0); axis off;
subplot(1,2,2); imagesc(1-scalpGender1); axis off;
set(gcf, 'color', 'w', 'paperpositionmode', 'auto', 'position', [118   337   712   306]);
print('-djpeg', 'scalptopo.jpg');

%%
figure; 
finaldata = [ 1-scalpGender0(:,:,1) 1-scalpGender0(:,:,2) 1-scalpGender0(:,:,3) ];
imagesc(finaldata); axis off; colormap(gray);
set(gcf, 'color', 'w', 'paperpositionmode', 'auto', 'position', [118   337   712/2*3   306]);
print('-djpeg', 'scalptoposplit.jpg');


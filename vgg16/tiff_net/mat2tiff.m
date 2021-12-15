function mat2tiff(m_data,labels,num_samples)
% this function converts a 3D mat file to grey scale tiff images and saves
% them in the current folder by default
    for i = 1:num_samples
        filename = [labels(i)+'/sample'+num2str(i)+'.tif'];
        t = Tiff(filename, 'w');
        tagstruct.ImageLength = size(m_data,1);
        tagstruct.ImageWidth = size(m_data,2);
        tagstruct.Photometric = 1; %Tiff.Photometric.MinIsWhite;
        tagstruct.BitsPerSample = 32;
        tagstruct.SamplesPerPixel = 1; %3 for RGB
        tagstruct.Software = 'appasamy-sc';
        tagstruct.SampleFormat = 3;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        t.setTag(tagstruct);
        
        t.write(single(m_data(:,:,i)));
        t.close();  
    end
end

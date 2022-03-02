function label_info = mat2tiff(m_data, labels, filepath)
% this function converts a 3D mat file to grey scale tiff images and saves
% them in the current folder by default
%
% filepath is the absolute path to the dataset where the final dataset will reside 
% for AWS s3 bucket, it could be (e.g. for training data)
% filepath = 's3://childminddata/train'
% else by default it is the present working directory (pwd)
  
  
    subjects = string(labels(:,1)); % The first column of labels contains the subject identifier
    foldernames =unique(subjects);
    num_subjects = length(foldernames);

    if ~exist(foldernames(1),'dir')
        cellfun(@mkdir,foldernames);
    end

     if isempty(filepath)
        filepath = pwd; %path to the dataset folder, default pwd
    end

    num_samples = size(m_data,3);
    subject_sample_counter = 1;

    for i = 1:num_samples
        
        filename = [subjects(i)+'/sample_'+num2str(subject_sample_counter)+'.tif'];
        t = Tiff(filename, 'w');
        tagstruct.ImageLength = size(m_data,1);
        tagstruct.ImageWidth = size(m_data,2);
        tagstruct.Photometric = 1; 
        tagstruct.BitsPerSample = 32;
        tagstruct.SamplesPerPixel = 1; %3 for RGB
        tagstruct.Software = 'appasamy-sc';
        tagstruct.SampleFormat = 3;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        t.setTag(tagstruct);
        
        t.write(single(m_data(:,:,i)));
        t.close();  

        label_col1 = fullfile(filepath,filename);
        label_info(i,:) = [label_col1 labels(i,:) subject_sample_counter];

%         writematrix(label_info,label_file,'Delimiter','tab','WriteMode','append');
    
        if  i<num_samples && subjects(i)==subjects(i+1)
            subject_sample_counter = subject_sample_counter+1;
        else
           subject_sample_counter = 1;
        end

    end

%     movefile(label_file, fileparts(pwd));
end


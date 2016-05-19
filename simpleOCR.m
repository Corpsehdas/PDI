
function simpleOcr()
    
    close all
    clc

    %% load dataset
    load('trainset.mat');
    load('className.mat');
    
    %% clasificación KNN
    model = fitcknn(trainset,className);
    model.NumNeighbors = 5;

    %% Predicción de instancias


    
    %% predicción de imagen completa   
    % se obtienen los segmentos de la imagen
    segments = getSegmentsFromImage('images/43.jpg',0);
    numObj = length(segments);
    %show image
    imageToTest = imread('images/43.jpg');
    figure; imshow(imageToTest); hold on;
    title('Imagen Original'); 
    
    %dibujar segmentos y 
    k= 1; 
    while k ~= numObj + 1
        if sum(sum(segments(k).image)) < 2500
            segments(k) = [];  
            numObj = numObj  - 1;
        end  
        label = predictionGivenImage(model,segments(k).image);
        rectangle('Position', segments(k).bBox,'EdgeColor','r');
        text(segments(k).bBox(1) + segments(k).center(2),segments(k).bBox(2)... 
            + segments(k).center(1),num2str(label),'Color','r','FontSize',15);
        k = k+1;
    end    
end

function predictionGivenClass(classExpected, model)
    %% Predicción de una Instancia
    imgTest = imread(['trainingSet/' num2str(classExpected) '.jpg']);
    label = predictionGivenImage(model,imgTest);
    disp(['expected:' num2str(classExpected) ' - predicted:' num2str(label)]);
end

function [label] = predictionGivenImage(model,imgTest)
    instance4test = getFeatures(imgTest);
    label = predict(model,instance4test);
end

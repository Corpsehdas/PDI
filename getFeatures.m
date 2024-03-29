function [features] = getFeatures(img, DEBUG)

    %casting
    img = double(img);
    %contador de caracteristicas
    cont = 1;
    [nFilas, nCols] = size(img);
    center = [ceil(nFilas/2), ceil(nCols/2)];
        
    shrink = bwmorph(img,'shrink',Inf);
    spur = bwmorph(shrink,'spur',Inf);

               
    %% raz�n nFilas/nCols
    features(cont) = nFilas/nCols;  
    cont = cont + 1;

    %% razon de area letra - imagen
    features(cont) = sum(sum(spur))/nFilas*nCols;  
    cont = cont + 1;

    %% centroide X, centroide Y
    [y, x] = find( spur );
    centroid = [mean(x) mean(y)];
    features(cont) = centroid(1);  
    cont = cont + 1;
    features(cont) = centroid(2);  
    cont = cont + 1;
    
    %% distancia del centro al centroide
    features(cont) = sqrt( ...
        (center(1,1) - centroid(1))^2 + ...
        (center(1,2) - centroid(2))^2);    
    cont = cont + 1;
        
    %%  numero de euler: e=#deObjetos - #deAgujerosEnLosObjetos
    feature_euler  = regionprops(spur, 'EulerNumber');
    features(cont) = feature_euler(1).EulerNumber;  
    cont = cont + 1;

    %% orientaci�n de la imagen  (in degrees ranging from -90 to 90 degrees) 
    feature_orientation  = regionprops(spur, 'Orientation');
    features(cont) = feature_orientation(1).Orientation;  
    cont = cont + 1;

    %% STD X,STD Y
    features(cont) = mean(std(spur));  
    cont = cont + 1;
    features(cont) = mean(std(spur'));  
    cont = cont + 1;
    
    %% procesar por bloque
    nBlocks = 5;
    sizeBlockFila = nFilas/nBlocks;
    sizeBlockCol = nCols/nBlocks;    
    filasProcesadas = 0;    
    for f = 1:sizeBlockFila+1:nFilas
        colsProcesadas = 0;
        for c = 1:sizeBlockCol+1:nCols
            finFila = round(f + sizeBlockFila -1);
            finCol = round(c + sizeBlockCol - 1);
            if finFila>nFilas
                finFila = nFilas;
            end
            if finCol>nCols
                finCol = nCols;
            end
            imgBlock = spur(round(f):finFila,round(c):finCol);
            [m,n] = size(imgBlock);
            %atributo razon caracter - bloque
            features(cont) = sum(sum(imgBlock))/(m*n);  
            cont = cont + 1;
            colsProcesadas = colsProcesadas +1;
        end        
        %asegurar que las cols procesadas sean nBloques
        for i = colsProcesadas:(nBlocks-1)
            features(cont) = 0;
            cont = cont + 1;
        end              
        filasProcesadas = filasProcesadas +1;
    end    
    %asegurar que las cols procesadas sean nBloques
    for i = filasProcesadas:(nBlocks-1)
        features(cont) = 0;
        cont = cont + 1;
    end

    %% numero de huecos
    filled = imfill(img, 'holes');
    holes = filled & ~img;
    bigholes = bwareaopen(holes, 200);
    stats = regionprops(bigholes, 'Area');
    nHoles = length(find([stats.Area]>10));
    features(cont) = nHoles;
    cont = cont + 1;
        

    %% numero de end points
        endPoints = bwmorph(spur,'endpoints');
        branchpoints = bwmorph(spur,'branchpoints');
        se = strel('disk',round(nFilas/12));
        endPoints_dilated = imdilate(endPoints,se);    
        branchpoints_dilated = imdilate(branchpoints,se);    
        stats = regionprops(endPoints_dilated, 'Area');
        nEndPoints = length(find([stats.Area]>10));
        
        features(cont) = nEndPoints;
        cont = cont + 1;
        
     %% numero de branch points               
        stats = regionprops(branchpoints_dilated, 'Area');
        nBranchPoints = length(find([stats.Area]>10));
        features(cont) = nBranchPoints;
        cont = cont + 1;


end
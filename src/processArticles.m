function processArticles(databaseFile)
    % Carregar os dados
    
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Inicializar Bloom Filter
    bf = false(1, 1000);
    hashFunc = @simpleHash;
    
    % Carregar modelo Naïve Bayes
    load('naiveBayesModel.mat', 'mdl');
    
    % Processar cada artigo
    for i = 1:height(data)
        % Verificar duplicação
        [bf, isNew] = addToBloomFilter(bf, data.title(i), hashFunc);
        if ~isNew
            fprintf('Artigo duplicado: %s\n', data.title(i));
            continue;
        end
        
        % Classificar artigo
        bow = bagOfWords(data.title(i));
        prediction = predict(mdl, bow);
        
        % Exibir resultados
        fprintf('Artigo: %s\nClassificação: %s\n', data.title(i), string(prediction));
    end
end

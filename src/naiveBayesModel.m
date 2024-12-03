function naiveBayesModel(databaseFile)
    % Carregar os dados
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Extrair títulos e rótulos
    titles = data.title;
    labels = categorical(data.real);
    
    % Criar bag-of-words
    bow = bagOfWords(titles);
    
    % Treinamento
    mdl = fitcnb(bow.Counts, labels);
    
    % Salvar modelo treinado
    save('naiveBayesModel.mat', 'mdl');
    disp('Modelo treinado e salvo.');
end

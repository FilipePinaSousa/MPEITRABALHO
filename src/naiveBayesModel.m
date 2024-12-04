function naiveBayesModel(databaseFile)
    % Carregar os dados (Load the data)
    data = readtable(databaseFile, 'TextType', 'string'); % Add proper argument
    
    % Extrair títulos e rótulos (Extract titles and labels)
    titles = data.title;
    labels = categorical(data.real);
    
    % Criar bag-of-words (Create bag-of-words)
    bow = bagOfWords(titles);
    
    % Treinamento (Train the Naive Bayes model)
    mdl = fitcnb(bow.Counts, labels);
    
    % Salvar modelo treinado (Save the trained model)
    save('naiveBayesModel.mat', 'mdl');
    disp('Modelo treinado e salvo.');
end

function realOrFake = classifyArticle(title)
    % Carregar o modelo treinado
    load('naiveBayesModel.mat', 'mdl');
    
    % Converter o título para bag-of-words
    bow = bagOfWords(title);
    
    % Predizer se a notícia é real ou fake
    prediction = predict(mdl, bow);
    realOrFake = prediction;  % Retorna 1 (real) ou 0 (falsa)
end

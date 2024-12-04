function realOrFake = classifyArticle(title, url)
    % Carregar o modelo treinado
    load('naiveBayesModel.mat', 'mdl');
    
    % Converter o título para bag-of-words
    bow = bagOfWords(title);
    
    % Extrair o domínio da URL (considerando que a URL já foi fornecida)
    domain = extractDomain(url);
    
    % Transformar o domínio em uma representação utilizável (pode ser um número binário, etc.)
    % Vamos considerar que o domínio é "confiável" ou "não confiável" baseado em uma lista de domínios conhecidos
    domainFeature = isReliableDomain(domain);
    
    % Combinar as características do título (bag-of-words) com a característica do domínio
    features = [bow, domainFeature];
    
    % Predizer se a notícia é real ou fake
    prediction = predict(mdl, features);
    
    % Retorna 1 (real) ou 0 (falsa)
    realOrFake = prediction;
end

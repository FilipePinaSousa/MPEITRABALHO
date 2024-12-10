function test_naiveBayesModel(testDataFile, modelFile)
    % Carregar os dados de teste e o modelo
    testData = readtable(testDataFile, 'TextType', 'string');
    load(modelFile, 'model');

    % Processar os dados como na função de treinamento
    titles = string(testData.title);
    domains = string(testData.source_domain);
    labels = categorical(testData.real);

    % Gerar as características
    numInstances = length(titles);
    domainFeatures = zeros(numInstances, 1);
    titleFeatures = zeros(numInstances, 1);
    for i = 1:numInstances
        domainFeatures(i) = string2hash(domains(i));
        titleFeatures(i) = string2hash(titles(i));
    end
    features = [domainFeatures, titleFeatures];

    % Normalizar as características
    features = (features - min(features)) ./ (max(features) - min(features));

    % Prever a classe para cada instância
    predictions = zeros(numInstances, 1);
    for i = 1:numInstances
        scores = model.priors' .* prod(features(i, :) .^ model.condProbs, 2);
        [~, predictions(i)] = max(scores);
    end

    % Comparar as previsões com os rótulos reais
    accuracy = mean(predictions == labels);
    fprintf('Acurácia do modelo: %.2f%%\n', accuracy * 100);
end

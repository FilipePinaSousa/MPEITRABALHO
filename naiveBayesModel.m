function naiveBayesModel(databaseFile)
    % Carregar os dados
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Extrair títulos e rótulos
    titles = strtrim(string(data.title))';  % Garantir vetor linha
    domains = data.source_domain';         % Garantir vetor linha
    labels = categorical(data.real)';      % Garantir vetor linha
    
    % Verifique o tamanho original dos dados
    disp("Tamanho original de titles, domains e labels:");
    disp(size(titles));  % Exibe o tamanho de titles
    disp(size(domains)); % Exibe o tamanho de domains
    disp(size(labels));  % Exibe o tamanho de labels
    
    % Remover entradas inválidas (NA ou vazio) nos domínios
    % A remoção ocorre apenas quando o domínio é NA ou vazio
    validRows = ~ismissing(domains) & domains ~= "";
    
    % Aplicar o filtro em todos os dados: titles, domains, labels
    titles = titles(validRows);
    domains = domains(validRows);
    labels = labels(validRows);  % Certificar que labels são filtrados da mesma forma
    
    % Verifique o tamanho após a remoção de entradas inválidas
    disp("Tamanho após remoção de entradas inválidas (domínios ausentes ou vazios):");
    disp("Títulos válidos após o filtro:");
    disp(size(titles));  % Exibe o tamanho de titles
    disp("Domínios válidos após o filtro:");
    disp(size(domains)); % Exibe o tamanho de domains
    disp("Rótulos válidos após o filtro:");
    disp(size(labels));  % Exibe o tamanho de labels
    
    % Remover títulos vazios ou inválidos
    validTitles = titles ~= "";  % Excluir títulos vazios
    titles = titles(validTitles); % Atualizar títulos válidos
    domains = domains(validTitles); % Atualizar domínios
    labels = labels(validTitles);   % Atualizar rótulos
    
    % Verifique se o número de títulos válidos após o filtro corresponde ao tamanho esperado
    disp("Número de títulos válidos após o filtro de título vazio:");
    disp(length(titles));
    
    % Criar bag-of-words para os títulos
    bowTitles = bagOfWords(titles);
    countsTitles = bowTitles.Counts;  % Obter a matriz de contagem
    
    % Verifique as dimensões de countsTitles
    disp("Dimensões de countsTitles:");
    disp(size(countsTitles));  % Exibe o tamanho de countsTitles
    

    % Processar os domínios como uma variável categórica
    uniqueDomains = unique(domains);  % Obter domínios únicos
    domainFeatures = zeros(length(titles), length(uniqueDomains));  % Inicializar a matriz de características
    
    % Criar a matriz de características de domínios
    for i = 1:length(titles)
        domainIdx = strcmp(uniqueDomains, domains(i));  % Encontrar o índice do domínio
        domainFeatures(i, domainIdx) = 1;  % Definir a coluna correspondente ao domínio como 1
    end
    
    % Verifique as dimensões após a criação das características de domínio
    disp("Dimensões de domainFeatures:");
    disp(size(domainFeatures));  % Exibe o tamanho de domainFeatures
    
    % Concatenar todas as características
    % Certifique-se de que countsTitles e domainFeatures tenham o mesmo número de linhas
    if size(countsTitles, 1) ~= size(domainFeatures, 1)
        error('Número de títulos e domínios não coincidem!');
    end
    
    % Concatenar as contagens de palavras e as características de domínio
    % Converter domainFeatures para uma matriz esparsa para compatibilidade com countsTitles
    domainFeaturesSparse = sparse(domainFeatures);
    
    % Concatenar as contagens de palavras (sparse) e as características de domínio (dense convertidas para sparse)
    features = [countsTitles, domainFeaturesSparse];
    
    % Verifique as dimensões da matriz final de características
    disp("Dimensões de features:");
    disp(size(features));  % Exibe o tamanho de features
    
    % Treinar o modelo Naïve Bayes
    mdl = fitcnb(features, labels);
    
    % Salvar o modelo treinado
    save('naiveBayesModel.mat', 'mdl');
    disp('Modelo treinado e salvo.');
end

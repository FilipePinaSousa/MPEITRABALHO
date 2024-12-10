function findSimilarArticlesMinHash(databaseFile)
    % Ler a tabela de artigos
    disp('Lendo a tabela de artigos...');
    data = readtable(databaseFile, 'TextType', 'string');
    disp('Tabela de artigos carregada.');

    % Parâmetros para MinHash
    numHashes = 200;  % Número de funções de dispersão
    shinglesSize = 3;  % Tamanho do shingle
    threshold = 0.2;   % Limiar de similaridade para exibir títulos semelhantes
    fprintf('Número de hashes: %d, Tamanho do shingle: %d\n', numHashes, shinglesSize);

    % Criar MinHash assinaturas
    signatures = inf(height(data), numHashes);
    for i = 1:height(data)
        title = data.title(i);
        if strlength(title) < shinglesSize
            fprintf('Título ignorado (muito curto): %s\n', title);
            continue;
        end
        fprintf('Gerando shingles para o título: %s\n', title);
        shingles = generateShingles(title, shinglesSize);
        signatures(i, :) = generateMinHashWithString2Hash(shingles, numHashes);
        fprintf('Assinatura gerada para o título: %s\n', title);
    end

    % Lê o título de entrada do usuário
    userInput = input('Introduza um título: ', 's');
    if strlength(userInput) < shinglesSize
        disp('O título fornecido é muito curto.');
        return;
    end
    fprintf('Gerando assinatura para o título fornecido: %s\n', userInput);

    % Gera assinatura para o título fornecido
    userShingles = generateShingles(userInput, shinglesSize);
    userSignature = generateMinHashWithString2Hash(userShingles, numHashes);
    disp('Assinatura gerada para o título fornecido.');

    % Calcular distâncias e ordenar para títulos semelhantes
    distances = zeros(height(data), 1);
    for i = 1:height(data)
        distances(i) = sum(signatures(i, :) ~= userSignature) / numHashes;
    end
    [sortedDistances, indices] = sort(distances);  % Ordena as distâncias

    % Exibir os artigos mais similares com base nas distâncias ordenadas
    disp('Os títulos mais similares são:');
    similarArticles = {};
    for i = 1:min(10, height(data))  % Exibir até 10 títulos mais próximos
        idx = indices(i);  % Índice do artigo mais próximo
        fprintf('%s (Distância: %.4f)\n', data.title(idx), sortedDistances(i));
        similarArticles{end+1} = data.title(idx);  % Adiciona ao conjunto de artigos semelhantes
    end
    
    % Agora, procurar por artigos na mesma categoria ou com conteúdo similar
    disp('Recomendando artigos na mesma categoria...');
    recommendedArticles = recommendByCategory(data, userInput, similarArticles);
    
    disp('Artigos recomendados:');
    disp(recommendedArticles);
end

function recommendedArticles = recommendByCategory(data, userInput, similarArticles)
    % Agora vamos procurar palavras-chave no título fornecido para determinar
    % a categoria do artigo ou o tópico principal
    % Por exemplo, se o título contém "tecnologia", consideramos a categoria como "Tecnologia"
    
    % Exemplo simples: detectar palavras-chave no userInput para determinar a categoria
    keywords = ["tecnologia", "economia", "transformação digital", "inovação", "IA"];
    foundCategories = {};
    
    % Verificar quais palavras-chave estão presentes no título do usuário
    for i = 1:numel(keywords)
        if contains(lower(userInput), lower(keywords(i)))
            foundCategories{end+1} = keywords(i);
        end
    end
    
    if isempty(foundCategories)
        disp('Nenhuma categoria detectada no título fornecido.');
        foundCategories{end+1} = 'Geral';  % Categoria padrão
    end
    
    % Buscar artigos na mesma categoria ou com conteúdo semelhante
    recommendedArticles = {};
    for i = 1:height(data)
        % Verificar se o artigo pertence a uma das categorias encontradas
        articleCategory = data.category(i);  % Assumindo que a tabela tem uma coluna "category"
        
        % Se o artigo pertence a uma das categorias detectadas e não é um artigo já listado
        if any(ismember(foundCategories, articleCategory)) && ~ismember(data.title(i), similarArticles)
            recommendedArticles{end+1} = data.title(i);
        end
    end
end

function shingles = generateShingles(text, k)
    % Normalizar texto (minúsculas e remover caracteres não alfanuméricos)
    text = lower(regexprep(text, '[^\w\s]', ''));
    text = char(text); % Converter para char para manipulação

    % Gerar shingles de tamanho k
    shingles = {};
    if length(text) >= k
        for i = 1:(length(text) - k + 1)
            shingle = text(i:i + k - 1);
            shingles{end + 1} = shingle; % Adicionar shingle
        end
    else
        shingles = {text}; % Caso o texto seja menor que k
    end
end

function signature = generateMinHashWithString2Hash(shingles, numHashes)
    % Inicializar assinatura com infinito
    signature = inf(1, numHashes);

    % Gera hashes para cada shingle
    for i = 1:numHashes
        for j = 1:numel(shingles)
            hashValue = mod(string2hash(shingles{j}, 'djb2', i), 2^31 - 1);
            if hashValue < signature(i)
                signature(i) = hashValue; % Atualizar o valor mínimo
            end
        end
    end
end

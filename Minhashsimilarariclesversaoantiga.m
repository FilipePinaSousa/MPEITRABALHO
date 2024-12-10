function Minhashsimilarariclesversaoantiga(databaseFile)
    % Ler a tabela de artigos
    disp('Lendo a tabela de artigos...');
    data = readtable(databaseFile, 'TextType', 'string');
    disp('Tabela de artigos carregada.');

    % Exibe as colunas da tabela para garantir a correta referência
    disp('Colunas da tabela:');
    disp(data.Properties.VariableNames);

    % Parâmetros para MinHash
    numHashes = 200;  % Número de funções de dispersão
    shinglesSize = 3;  % Tamanho do shingle
    threshold = 0.2;   % Limiar de similaridade para exibir artigos semelhantes
    fprintf('Número de hashes: %d, Tamanho do shingle: %d\n', numHashes, shinglesSize);

    % Criar MinHash assinaturas para todos os artigos
    signatures = inf(height(data), numHashes);
    for i = 1:height(data)
        % Usando a coluna 'title' como conteúdo do artigo
        content = data.title(i);  % Usando o título para gerar MinHash
        if strlength(content) < shinglesSize
            fprintf('Artigo ignorado (muito curto): %s\n', data.title(i));
            continue;
        end
        fprintf('Gerando shingles para o artigo: %s\n', data.title(i));
        shingles = generateShingles(content, shinglesSize);
        signatures(i, :) = generateMinHashWithString2Hash(shingles, numHashes);
        fprintf('Assinatura gerada para o artigo: %s\n', data.title(i));
    end

    % Lê o título do artigo lido pelo usuário
    userInput = input('Introduza o conteúdo do artigo que você leu: ', 's');
    if strlength(userInput) < shinglesSize
        disp('O conteúdo fornecido é muito curto.');
        return;
    end
    fprintf('Gerando assinatura para o artigo fornecido.\n');

    % Gera assinatura para o artigo fornecido pelo usuário
    userShingles = generateShingles(userInput, shinglesSize);
    userSignature = generateMinHashWithString2Hash(userShingles, numHashes);
    disp('Assinatura gerada para o artigo fornecido.');

    % Calcular distâncias e ordenar
    distances = zeros(height(data), 1);
    for i = 1:height(data)
        distances(i) = sum(signatures(i, :) ~= userSignature) / numHashes;
    end

    % Filtra os artigos semelhantes (distâncias abaixo do limiar)
    similarArticles = distances < threshold;
    
    % Mostrar os artigos mais similares
    if any(similarArticles)
        disp('Os artigos mais similares são:');
        for i = 1:height(data)
            if similarArticles(i)
                fprintf('%s (Distância: %.4f)\n', data.title(i), distances(i));
            end
        end
    else
        disp('Nenhum artigo semelhante encontrado com o limiar especificado.');
    end
end

function shingles = generateShingles(text, k)
    % Normalizar texto (minúsculas e remover caracteres não alfanuméricos)
    disp('Normalizando texto e gerando shingles...');
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
    fprintf('Shingles gerados: %s\n', strjoin(shingles, ', '));
end

function signature = generateMinHashWithString2Hash(shingles, numHashes)
    % Inicializar assinatura com infinito
    disp('Gerando MinHash assinatura...');
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
    fprintf('Assinatura gerada: %s\n', mat2str(signature));
end

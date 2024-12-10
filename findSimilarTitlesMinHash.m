function findSimilarTitlesMinHash(databaseFile)
    % Ler a tabela de títulos
    disp('Lendo a tabela de títulos...');
    data = readtable(databaseFile, 'TextType', 'string');
    disp('Tabela de títulos carregada.');


    % Parâmetros para MinHash
    numHashes = 200;  % Altere para o número de funções de dispersão
    shinglesSize = 3;  % Tamanho do shingle
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

    % Calcular distâncias e ordenar
    distances = zeros(height(data), 1);
    for i = 1:height(data)
        distances(i) = sum(signatures(i, :) ~= userSignature) / numHashes;
    end
    [sortedDistances, indices] = sort(distances);

    % Mostrar os títulos mais similares
    disp('Os títulos mais similares são:');
    for i = 1:min(3, height(data))
        fprintf('%s (Distância: %.4f)\n', data.title(indices(i)), sortedDistances(i));
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
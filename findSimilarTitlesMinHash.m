function findSimilarTitlesMinHash(databaseFile)
    % Ler a tabela de títulos
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Limitar o número de títulos a 1000
    numTitles = min(1000, height(data));
    
    % Parâmetros para MinHash
    numHashes = 500;  % Aumentando o número de hashes
    shinglesSize = 8;  % Aumentando o tamanho dos shingles
    
    % Criar MinHash assinaturas
    signatures = zeros(numTitles, numHashes);
    for i = 1:numTitles
        shingles = generateShingles(data.title(i), shinglesSize);
        fprintf('Shingles do título %d: %s\n', i, strjoin(string(shingles), ', '));
        signatures(i, :) = generateMinHashWithString2Hash(shingles, numHashes);
    end
    
    % Comparar assinaturas e calcular similaridade
    for i = 1:numTitles
        for j = i+1:numTitles
            similarity = calculateMinHashSimilarity(signatures(i, :), signatures(j, :));
            fprintf('Similaridade entre os títulos:\n');
            fprintf('Título 1: %s\nTítulo 2: %s\nSimilaridade MinHash: %.2f\n\n', ...
                data.title(i), data.title(j), similarity);
        end
    end
end

function shingles = generateShingles(text, k)
    % Normalizar texto (minúsculas e remover caracteres não alfanuméricos)
    text = lower(regexprep(text, '[^\w\s]', ''));
    tokens = split(text); 

    % Remover palavras de parada (stop words)
    stopWords = ["the", "and", "to", "of", "in", "on", "a", "for", "with", "this", "at", "by", "an", "be", "as", "it", "was", "who", ...
    "is", "are", "were", "am", "been", "being", "has", "have", "had", "having", "do", "does", "did", "doing", "but", "if", ...
    "or", "because", "all", "any", "each", "some", "such", "no", "nor", "not", "only", "own", "same", "so", "than", "too", ...
    "very", "s", "t", "can", "will", "just", "don", "should", "now", "d", "ll", "m", "o", "re", "ve", "y", "ain", "aren", "couldn", ...
    "didn", "doesn", "hadn", "hasn", "haven", "isn", "ma", "mightn", "mustn", "needn", "shan", "shouldn", "wasn", "weren", "won", "wouldn"];

    tokens = tokens(~ismember(tokens, stopWords));

    % Gerar shingles de tamanho k
    shingles = {};
    if numel(tokens) >= k
        for i = 1:(numel(tokens) - k + 1)
            shingle = strjoin(tokens(i:i+k-1), ' ');
            shingles{end+1} = shingle;  % Armazenar shingles como células
        end
    else
        shingles = tokens;  % Caso o número de tokens seja menor que k
    end
end


function signature = generateMinHashWithString2Hash(shingles, numHashes)
    % Parâmetros para hashing
    numShingles = numel(shingles);
    signature = inf(1, numHashes);  % Inicializar assinatura com infinito
    
    % Utilizando MD5 como função de hash para evitar colisões
    for i = 1:numHashes
        for j = 1:numShingles
            % Calcular o hash com uma função MD5 (ou outra função de hash de sua escolha)
            hashValue = mod(string2hash(shingles{j}, 'md5', i), 2^31 - 1); 
            if hashValue < signature(i)
                signature(i) = hashValue;  % Atualizar o valor mínimo
            end
        end
    end
    
    % Exibir assinatura gerada para depuração
    disp(['Assinatura gerada: ', num2str(signature)]);
end

function similarity = calculateMinHashSimilarity(sig1, sig2)
    % Calcular a similaridade entre duas assinaturas MinHash
    similarity = sum(sig1 == sig2) / numel(sig1);  % Proporção de hashes iguais
end

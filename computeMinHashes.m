function minhashes = computeMinHashes(text, numHashes)
    % Divide o texto em palavras, remove stopwords e converte para minúsculas
    stopwords = ["a", "e", "de", "que", "do", "da", "dos", "das", "em", "um", "uma", "para", "por", "com", "sobre"];
    words = split(lower(text));  % Divide o texto em palavras
    words = setdiff(words, stopwords);  % Remove stopwords
    words = unique(words);  % Elimina palavras duplicadas
    
    % Inicializa os valores mínimos para cada função de hash
    minhashes = inf(1, numHashes);
    
    % Calcula hashes para cada palavra
    for i = 1:length(words)
        wordHash = simpleHash(words{i}, numHashes);  % Gera o hash para a palavra
        minhashes = min(minhashes, wordHash);  % Atualiza os valores mínimos
    end
end

function hashValues = simpleHash(word, numHashes)
    % Função que gera valores de hash para uma palavra com múltiplas funções
    hashValues = zeros(1, numHashes);
    
    % Para cada hash, cria uma semente com base na palavra
    for i = 1:numHashes
        rng(i + sum(double(word)));  % Semente baseada na palavra e na iteração
        hashValues(i) = mod(randi([0, 1e6]), 1e6);  % Gera o valor hash com modulação para evitar overflow
    end
end

function similarity = calculateJaccardSimilarity(title1, title2, numHashes)
    % Calcula os MinHashes dos dois títulos
    minhashes1 = computeMinHashes(title1, numHashes);
    minhashes2 = computeMinHashes(title2, numHashes);
    
    % Calcula a similaridade Jaccard aproximada
    similarity = sum(minhashes1 == minhashes2) / numHashes;  % Calcula a fração de hashes iguais
end

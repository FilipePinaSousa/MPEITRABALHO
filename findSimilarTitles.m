function findSimilarTitles(databaseFile)
    data = readtable(databaseFile, 'TextType', 'string');
    
    % Comparar todos os pares de títulos
    for i = 1:height(data)
        for j = i+1:height(data)
            similarity = calculateJaccardSimilarity(data.title(i), data.title(j));
            fprintf('Similaridade entre os títulos:\n');
            fprintf('Título 1: %s\nTítulo 2: %s\nSimilaridade de Jaccard: %.2f\n\n', ...
                data.title(i), data.title(j), similarity);
        end
    end
end

function similarity = calculateJaccardSimilarity(title1, title2)
    % Tokenizar e normalizar os títulos
    tokens1 = normalizeTokens(title1);
    tokens2 = normalizeTokens(title2);
    
    % Criar conjuntos únicos
    set1 = unique(tokens1);
    set2 = unique(tokens2);
    
    % Calcular interseção e união
    intersection = intersect(set1, set2);
    unionSet = union(set1, set2);
    
    % Calcular a similaridade de Jaccard
    similarity = numel(intersection) / numel(unionSet);
end

function tokens = normalizeTokens(title)
    title = lower(title);
    
    title = regexprep(title, '[^\w\s]', ''); 
    
    tokens = split(title);
    
    % Remova stop words (personalizar)
    stopWords = ["to", "the", "and", "of", "is", "a", "in", "for", "on"];
    tokens = tokens(~ismember(tokens, stopWords));
    
    tokens = tokens(~cellfun('isempty', tokens));
end


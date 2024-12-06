function hash = string2hash(str)
    % Verificar se a entrada é uma string válida
    if ~isstring(str) || isempty(str) || str == "NA" || strtrim(str) == ""
        str = "default";
    end
    
    % Garantir que str seja tratado como string para evitar NaN
    if ~ischar(str)
        str = char(str);
    end

    % Usar algoritmo DJB2
    hash = 5381; 
    for i = 1:length(str)
        hash = mod(hash * 33 + double(str(i)), 2^32);
    end
end

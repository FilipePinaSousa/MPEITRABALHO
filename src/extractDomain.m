function domain = extractDomain(url)
    % Extrair o domínio principal da URL
    % Exemplo: 'https://www.bbc.com/news' -> 'bbc.com'
    [~, domain] = urlsplit(url);
    domain = extractBetween(domain, '://', '/');
    domain = domain{1};  % Retirar a primeira ocorrência do domínio
end

function data = getmarketdata(symbol, startDate, endDate, interval, dataChoice)
    % A fork from Artem Lenskiy
    %
    % Downloads market data from Yahoo Finance for a specified symbol and 
    % time range.
    % 
    % INPUT:
    % symbol    - is a ticker symbol i.e. 'AMD', 'BTC-USD'
    % startdate - the date from which the market data will be requested
    % enddate   - the market data will be requested till this date
    % interval  - the market data will be returned in this intervals
    % supported intervals are '1d', '5d', '1wk', '1mo', '3mo'
    %
    % Example: 
    %   data = getmarketdata('AMD', '1-Jan-2018', datetime('today'), '5d');
    % 
    % 1 to 6 for "Date", "Open", "High", "Low", "Close", "Adj Close", "Volume"
    % Some of the improvements that could be added:
    % 1) Augment the two functions in the bottom that construct the uris
    % 2) Return all the data and make the consumer choose which data to
    % throw away since HTTP calls are expensive.
    % 3) Find a better way to refactor the big and ugly method getrequestobjectandcrumb
    % 4) Don't violate any of the line thresholds.
    
    symbol = upper(symbol);
    httpOptions = matlab.net.http.HTTPOptions(...
    'ConnectTimeout', 20, ...
    'DecodeResponse', 1, ...
    'Authenticate', 0, ...
    'ConvertResponse', 0);
    [requestObject, crumb] = getrequestobjectandcrumb(symbol, httpOptions, interval);
    startDate = datetime(startDate);
    endDate = datetime(endDate);
    uri = constructyahoourifordata(symbol, startDate, endDate, interval, crumb);
    [response, ~, ~] = requestObject.send(uri, httpOptions);
    
    if(strcmp(response, 'NotFound'))
        throw('No data available');
    end

    data = processdata(response.Body.Data, dataChoice);
end
 
function [requestObject, crumb] = getrequestobjectandcrumb(symbol, httpOptions, interval)
    timeNow = datetime();
    uri = constructyahoouriforfields(symbol, timeNow, timeNow, interval);
    
    %% Extract the crumb value 
    % The ideas is taken from here:
    % http://blog.bradlucas.com/posts/2017-06-02-new-yahoo-finance-quote-download-url/
    % The while loop is used to make sure that generated crumb value does
    % not contains '\', since requestObj.send does not correctly send URLs
    % with slash
    crumb = "\";
    while(contains(crumb, '\'))
        requestObject = matlab.net.http.RequestMessage();
        [response, ~, ~]  = requestObject.send(uri, httpOptions);
        index = regexp(response.Body.Data, '"CrumbStore":{"crumb":"(.*?)"}');
        if(isempty(index))
            error(['Possibly ', symbol ,' is not found']);
        end
        crumb = response.Body.Data.extractBetween(index(1)+23, index(1)+33);
    end
    
    cookieFields = response.getFields('Set-Cookie');
    contentFields = response.getFields('Content-Type');
        
    if isempty(cookieFields)
        throw('Check ticker symbol and that Yahoo provides data for it');
    end
    
    cookieInfos = cookieFields.convert(uri);
    contentInfos = contentFields.convert();
    requestObject = requestObject.addFields(matlab.net.http.field.CookieField([cookieInfos.Cookie]));
    requestObject = requestObject.addFields(matlab.net.http.field.ContentTypeField(contentInfos));
    requestObject = requestObject.addFields(matlab.net.http.field.GenericField('User-Agent', 'Mozilla/5.0'));
end
 
function uri = constructyahoouriforfields(symbol, startdate, enddate, interval)
uri = matlab.net.URI(...
    ['https://finance.yahoo.com/quote/', symbol, '/history'],...
    'period1', num2str(uint64(posixtime(startdate)), '%.10g'), ...
    'period2', num2str(uint64(posixtime(enddate)), '%.10g'), ...
    'interval', interval, ...
    'events', 'history', ...
    'frequency', interval, ...
    'guccounter', 1, ...
    'literal');
end
 
function uri = constructyahoourifordata(symbol, startdate, enddate, interval, crumb)
uri = matlab.net.URI(['https://query1.finance.yahoo.com/v7/finance/download/', upper(symbol) ],...
        'period1',  num2str(uint64(posixtime(startdate)), '%.10g'),...
        'period2',  num2str(uint64(posixtime(enddate)), '%.10g'),...
        'interval', interval,...
        'events',   'history',...
        'crumb',    crumb,...
        'literal');
end

function data = processdata(data, dataChoice)
    records = data.splitlines;
    header = records(1).split(',');
    content = zeros(size(records, 1) - 2, size(header, 1) - 1);
    for i = 1:size(records, 1) - 2
        items = records(i + 1).split(',');
        content(i, :) = str2double(items(2:end)); % Discard the date
    end
    data = content(:, dataChoice);
end
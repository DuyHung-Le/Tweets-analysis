function data = getData(fileName)
% GETDATA take a file as an input and read all data from that file,
% do a little bit processing and return a cell containing structured data.

    data = readtable(fileName,'ReadVariableNames', false);
    % ('ReadVariableNames', false) indicates that the file has no column heading

    % Convert the table to a cell
    data = table2cell(data);

    % Convert the cell to matrix of strings in order to process more easily
    X_string = string(data);

    % Now we move all the tweets from the non-column A to column A
    for i = 1: length(data)
        if X_string(i, 2) ~= ''
            data = [data; data(i,2) 0 0];
        end
        if X_string(i, 3) ~= ''
            data = [data; data(i,3) 0 0];
        end
    end

    % We need only the first column
    data = data(:,1);
end

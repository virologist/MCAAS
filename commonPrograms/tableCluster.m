function [virusCluster serumCluster] = tableCluster(fullTable, clusterVec, subTable)
%% tableCluster selects the sub HI table in the specified clusters, and  
%  returns the indices of the viruses and serum in each cluster.
%
%  Usage:
%        tableCluster    with less than 3 parameters gives this help 
%        tableCluster(fullTable,clusterVec,subTable)
%  Input: 
%        fullTable: a tab deliminated file with the following format
%                    2      \tab  3
%                    ID     \tab  serum1 \tab serum2 \tab serum
%                 reference \tab     0   \tab    0   \tab   0
%                  virus1   \tab  data11 \tab data12 \tab data13
%                  virus2   \tab  data21 \tab data22 \tab data23
%        clusterVec: a cell array of strings contains the cluster names
%        subTable: the sub HI table with viruses in the clusters
%  Output:
%        virusCluster: the clusters of viruses
%        serumCluster: the clusters of serum
%
%  Revision Date : 6th Jan, 2012
%  Author: Jialiang Yang  CVM, MSU, jyang@cvm.msstate.edu

%% Input checking
if nargin < 3
    help tableCluster
    return
else
    % check fullTable
    if ~ischar(fullTable)
        error('fullTable must be a character array!')
    end
    
    % check subTable
    if ~ischar(subTable)
        error('subTable must be a character array!')
    end
    
    % check virus cluster
    if ~iscellstr(clusterVec)
        error('virusVec must be a cell array of strings containing virus cluster names!')
    end
end

constCluster;

%% construct sub HI table: Find the indices of virus and serum for each cluster

% check validality and read HI table
% -------------------------------------------------------------------------
nCluster = numel(clusterVec);      % the number of clusters selected
clusterNum = zeros(nCluster,1);

% check the validality of clusterVec
for i = 1: nCluster
    indVec = strcmpi(clusterVec{i}, CLUSTERNAME);
    
    if ~any(indVec)
        error('cluster ''%s'' is not defined in CLUSTERNAME', clusterVec{i});
    else
        clusterNum(i) = find(indVec == 1);
    end
end

[dataHI, virusName, serumName, reference] = readTable(fullTable);

nVirus = numel(virusName);
nSerum = numel(serumName);
% -------------------------------------------------------------------------

% retrieve virus  in the clusters 
% -------------------------------------------------------------------------
vCluster = cell(nCluster,1);

% initialize
for i = 1: nCluster
    vCluster{i} = [];
end

rowSelect = [];

for i = 1: nVirus
    for j = 1: nCluster
        if any(strcmpi(virusName{i}, CLUSTER{clusterNum(j)}))
            rowSelect = [rowSelect; i];
            
            vCluster{j} = [vCluster{j} i];
        end
    end
end
% -------------------------------------------------------------------------

% retrieve serum  in the clusters 
% -------------------------------------------------------------------------
sCluster = cell(nCluster,1);
virusCluster = cell(nCluster,1);
serumCluster = cell(nCluster,1);

% initialize
for i = 1: nCluster
    sCluster{i} = [];
end

colSelect = [];

for i = 1: nSerum
    for j = 1: nCluster
        if any(strcmpi(serumName{i}, SERUMCLUSTER{clusterNum(j)}))
            colSelect = [colSelect; i];
            
            sCluster{j} = [sCluster{j} i];
        end
    end
end

% find the relative position
for i = 1: nCluster
    [commonVirus irowSelect] = intersect(rowSelect, vCluster{i});
    virusCluster{i} = irowSelect;
    
    [commonSerum icolSelect] = intersect(colSelect, sCluster{i});
    serumCluster{i} = icolSelect;
end
% -------------------------------------------------------------------------

% write to new sub table
% -------------------------------------------------------------------------
virusName = virusName(rowSelect);
serumName = serumName(colSelect);
reference = reference(colSelect);
dataCluster = dataHI(rowSelect,colSelect);
writeTable(subTable, dataCluster, virusName, serumName, reference)

end
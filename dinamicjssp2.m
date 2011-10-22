function []=dinamicjssp2(graph,machine,ngraph,nmachine,newjobtime)
%10042011

%membuat matriks simpul untuk mempermudah proses manipulasi data
nodes=zeros(size(graph,1),size(graph,2));
k=1;
for i=1:size(graph,1)
    for j=1:size(graph,2)
        nodes(i,j)=k;
        k=k+1;
    end
end

%parameter algoritma semut
Q = 1;
a = 1;
b = 1;
p =0.5;
t =0.01;
mactime=zeros(1,size(graph,2)); %semua mesin dalam keadaan bebas, setup time 0
jobtime=zeros(1,size(graph,1));

%cari rute terbaik dengan algoritma semut
[bestrute,setuptimes,machines]=ACO(graph,machine,nodes,Q,a,b,p,t,mactime,jobtime);

fprintf('makespan terkecil sebelum job baru datang adalah %d satuan waktu \n',max(bestrute));

%tampilkan hasil dari rute terbaik dalam bentuk diagram
subplot(2,1,1);
title({' ';' ';'Diagram hubungan waktu dengan job sebelum ada penambahan job';' '});
ylabel('Job');
xlabel('Waktu');
showmap(graph,bestrute,setuptimes,machines);

%cari dan simpan operasi yang berjalan sebelum job baru datang
column=2;
tempgraph=graph;
for i=2:size(bestrute,2)-1
    if(setuptimes(1,i)<newjobtime)
        selectednode(1,column)=bestrute(1,i);
        selectednodesetuptime(1,column)=setuptimes(1,i);
        selectednodemachines(1,column)=machines(1,i);
        column=column+1;
        row=ceil(bestrute(1,i)/size(graph,2));
        columns=mod(bestrute(1,i),size(graph,2));
        if(columns==0)
            columns=3;
        end
        tempgraph(row,columns)=0;
    end
end
selectednode(1,column)=0;
subplot(2,1,2);
title({' ';' ';'Diagram hubungan waktu dengan job setelah ada penambahan job';' '});
ylabel('Job');
xlabel('Waktu');
showmap(graph,selectednode,selectednodesetuptime,selectednodemachines);

%machine time dan jobtime yang baru
for i=2:size(selectednode,2)-1
    row=ceil(selectednode(1,i)/size(graph,2));
    column=mod(selectednode(1,i),size(graph,2));
    if(column==0)
        column=3;
    end
    mactime(1,machine(row,column))= selectednodesetuptime(1,i)+graph(row,column);
    jobtime(1,row)= selectednodesetuptime(1,i)+graph(row,column);
end

%susun graf baru dari operasi yang belum dikerjakan ditambah job yang
%datang
newgraph = zeros(size(graph,1),size(graph,2));
newmachine = zeros(size(graph,1),size(graph,2));
for i=1:size(tempgraph,1)
    column=1;
    for j=1:size(tempgraph,2)
        if(tempgraph(i,j)~=0)
            newgraph(i,column)=tempgraph(i,j);
            newmachine(i,column)=machine(i,j);
            column=column+1;
        end
    end
end

%membuat matriks simpul untuk mempermudah proses manipulasi data
nnodes=zeros(size(ngraph,1),size(ngraph,2));

k=1;
for i=1:size(ngraph,1)
    for j=1:size(ngraph,2)
        nnodes(i,j)=k;
        k=k+1;
    end
end

for i=1:size(ngraph,1)
    jobtime = [jobtime newjobtime];
end

newgraph=[newgraph;ngraph];
newmachine=[newmachine;nmachine];
k=1;
for i=1:size(newgraph,1)
    for j=1:size(newgraph,2)
        newnodes(i,j)=k;
        k=k+1;
    end
end

%cari rute terbaik menggunakan algoritma semut
[bestrute,setuptimes,machines]=ACO(newgraph,newmachine,newnodes,Q,a,b,p,t,mactime,jobtime);

fprintf('makespan terkecil setelah job baru datang adalah %d satuan waktu \n',max(bestrute));

showmap(newgraph,bestrute,setuptimes,machines);
function []= sp_ld1_main(casenum,ldlvnum)
% casenum = 24;
casenum=num2str(casenum);
casestr=strcat('case',casenum);
mpc0=load(casestr);
mpc0=mpc0.mpc;

% ldlvnum = 1;
ldlvnum=num2str(ldlvnum);
ldlvstr=strcat('ld1_lv',ldlvnum);
ldlv=load(ldlvstr);
ldlv=ldlv.ldlv;

CtgLevelMax = 5;
[ CtgList, CpntList ] = CreatSECtgList(mpc0, CtgLevelMax);
[lc0,spnum0]=sp_ld1_cal(mpc0,ldlv);

CtgNum = size(CtgList{1},1);
lc1=zeros(CtgNum ,1);
spnum1=zeros(CtgNum ,1);
stnum=size(CtgList{2},1);
lc2=zeros(stnum,1);
spnum2=zeros(stnum,1);

tic;
CtgListTmp = CtgList{1};
for i=1:CtgNum
   mpc=mpc0;
    CtgCpntNo = CtgListTmp(i,1);       % 故障支路详细列表
     CtgCpntList = CpntList(CtgCpntNo, :);
      CtgGenList = (1 == CtgCpntList(:, 1));
      CtgBrList = (2 == CtgCpntList(:, 1));
       mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
        mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];
   [lc1(i),spnum1(i)]=sp_ld1_cal(mpc,ldlv);
end

CtgListTmp = CtgList{2};
for i =1:stnum 
   mpc=mpc0;
     CtgCpntNo = CtgListTmp(i,1:2);       % 故障支路详细列表
     CtgCpntList = CpntList(CtgCpntNo, :);
      CtgGenList = (1 == CtgCpntList(:, 1));
      CtgBrList = (2 == CtgCpntList(:, 1));
       mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
        mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];
   [lc2(i),spnum2(i)]=sp_ld1_cal(mpc,ldlv);
      if (mod(i,1000)==0)
       disp(i);
   end
end

CtgListTmp = CtgList{3};
lc3=zeros(size(CtgListTmp,1),1);
spnum3=zeros(size(CtgListTmp,1),1);
for i =1:size(CtgListTmp,1)
   mpc=mpc0;
     CtgCpntNo = CtgListTmp(i,1:3);       % 故障支路详细列表
     CtgCpntList = CpntList(CtgCpntNo, :);
      CtgGenList = (1 == CtgCpntList(:, 1));
      CtgBrList = (2 == CtgCpntList(:, 1));
       mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
        mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];
   [lc3(i),spnum3(i)]=sp_ld1_cal(mpc,ldlv);
      if (mod(i,3000)==0)
       disp(i);
   end
end

CtgListTmp = CtgList{4};
lc4=zeros(size(CtgListTmp,1),1);
spnum4=zeros(size(CtgListTmp,1),1);
for i =1:size(CtgListTmp,1)
   mpc=mpc0;
     CtgCpntNo = CtgListTmp(i,1:4);       % 故障支路详细列表
     CtgCpntList = CpntList(CtgCpntNo, :);
      CtgGenList = (1 == CtgCpntList(:, 1));
      CtgBrList = (2 == CtgCpntList(:, 1));
       mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
        mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];
      [lc4(i),spnum4(i)]=sp_ld1_cal(mpc,ldlv);
      if (mod(i,30000)==0)
       disp(i);
   end
end

CtgListTmp = CtgList{5};
lc5=zeros(size(CtgListTmp,1),1);
spnum5=zeros(size(CtgListTmp,1),1);
for i =1:size(CtgListTmp,1)
   mpc=mpc0;
     CtgCpntNo = CtgListTmp(i,1:5);       % 故障支路详细列表
     CtgCpntList = CpntList(CtgCpntNo, :);
      CtgGenList = (1 == CtgCpntList(:, 1));
      CtgBrList = (2 == CtgCpntList(:, 1));
       mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
        mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];
      [lc5(i),spnum5(i)]=sp_ld1_cal(mpc,ldlv);
      if (mod(i,50000)==0)
       disp(i);
   end
end
time=toc

IISE5;
spnum=mean([spnum0;spnum1;spnum2;spnum3;spnum4;spnum5]);
savestr=strcat('sp_ld1_cs',casenum,'_lv',ldlvnum,'.mat');
% save(savestr,'lc0','lc1','lc2','lc3','lc4','LC','LC1','LC2','LC3','LC4','IISELC','IISELC1','IISELC2','IISELC3','IISELC4','spnum','spnum0','spnum1','spnum2','spnum3','spnum4','time');
save(savestr,'lc0','lc1','lc2','lc3','lc4','lc5','LC','LC1','LC2','LC3','LC4','LC5','IISELC','IISELC1','IISELC2','IISELC3','IISELC4','IISELC5','spnum','spnum0','spnum1','spnum2','spnum3','spnum4','spnum5','time');
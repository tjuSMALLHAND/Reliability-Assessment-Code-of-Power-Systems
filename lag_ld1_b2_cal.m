  function [lc,xbb,num,lagnum,n,k]=lag_ld1_b2_cal(mpc,ldlv,A,b,c,xbb,de1,de2)
    num = 1;                            %��¼���˼����Ż���ֱ�����
    lagnum =0;
    o=size(mpc.bus,1);
    p=size(mpc.gen,1);
    q=size(mpc.branch,1);
    n = size(xbb,2);
    ldlvnum=size(ldlv,1);
    de1 = de1 + 2*o;
    b(de1) = 0;                         %�������������Ϊ0
    de2_size = size(de2,1);             %de2_size����ɾ��������·
    %% ��·�ع�
    if de2_size ~=  0                   %��������漰��·--A,b,c�ؽ�
        A(1:o,1:o) = 0;
        B=zeros(o);
       for i=1:q
           B(mpc.branch(i,1),mpc.branch(i,2)) = B(mpc.branch(i,1),mpc.branch(i,2))+ mpc.branch(i,3);
           B(mpc.branch(i,2),mpc.branch(i,1)) =  B(mpc.branch(i,2),mpc.branch(i,1))+ mpc.branch(i,3);
       end
       s = -sum(B);
       for i=1:o
           B(i,i)=s(i);
       end  
        A(1:o,1:o)=-B;                  %A ���Ͻ�B'�Ĺ���
        de3 = de2 + 2*o + p;            %ɾ��������·��branch ij
        de4 = de2 + 2*o + p + q + de2_size;
        A(de4,:) = [];
        A(de3,:) = [];
        de5 = de2 + 3*o + 2*p;          %ɾ��������·���ɳڱ���yij
        de6 = de2 + 3*o + 2*p + q + de2_size;
        A(:,de6) = [];
        A(:,de5) = [];
        c(de6) = [];                    %ɾ���ɳڱ�����Ӧ�ļ�ֵϵ��
        c(de5) = [];
        b(de4) = [];                    %ɾ��b�й�����·����Լ����
        b(de3) = [];
    end  
 %% Core Part
        lc = 0;
        sp.invB = 0;
        sp.w = 0;
for ldi = 1 : ldlvnum
        n = size(xbb,2); %------
        b(mpc.area)=mpc.bus(mpc.area).*ldlv(ldi,1);
        b(o+1:2*o)=b(1:o);     
        k=0;                            %��k��¼�ڼ����ҵ����Ż�
%---------------------------------------------���˷�������һ�Σ�------------------------------------------------------
      if ldi == 1 
          for i = n:-1:1
              if i == n-15                    %����search������15
                  break;
              end  
                  xb = xbb{i};
            if size(xb,1) == 2*o + p + 2*q  %��ͬ�׻�����·��Ӧ��·���������Ӧ�����
                      BB = A(:,xb);                                                 %ͨ��xb������Ż�BB�������Ǵ�BC��ΪA�仯��
                      w = c(xb) / BB;                                               %------------��ʱ����----------------
                      index = (xb>o&xb<=2*o)|xb>3*o+p;
                      x = BB \ b;
                  if isnan(w) == 0                                          % w ����NaNԪ��
                      if x(index) > -1e-8        
                          if c - w * A > -1e-8
                              k = n - i + 1;                                      % k ��¼�ڼ����ҵ���ƥ������Ż�λ��xb
                              plc = w * b;
                              invB = inv(full(BB));
                              judge = find((xb>o&xb<=2*o)|xb>3*o+p);
                              lc = lc + plc * ldlv(ldi,2);
                              num = 0;                                       %num = 0��ʾ�ҵ����Ż�
                              xbb = xb;
                              break;                                        %�ҵ����˳�ѭ��
                          end
                      end
                  end
            end
          end
          if  num == 1               %�����һ��������û�ҵ�-->���淽��Mosek
                [plc,xb]=lag_mskopt(A,b,c,o);
                lc = lc + plc * ldlv(ldi,2);
                judge = find((xb>o&xb<=2*o)|xb>3*o+p);
                BB = A(:,xb);             
                w = c(xb) / BB;
                xbb = xb;
                invB =  inv(full(BB)); %�����Ա��������ˮƽ�µļ���
                lagnum = 1;
                n = n + 1;
          end
                spnum = 1;
                sp(spnum).invB = invB(judge,:);
                sp(spnum).w = w;
%---------------------------------------------ʱ�为�ɣ���һ��֮��--------------------------------------------------
      else                                %��1������ˮƽ֮��
                flag = 0;
                for i = spnum:-1:max(spnum-1,1)
                    if sp(i).invB * b > -1e-8 
                        plc = sp(i).w * b;
                        flag = 1;
                        break;
                    end
                end
                if flag == 0
                    spnum = spnum + 1;
                    [plc,xb] = lag_mskopt(A,b,c,o);   
                    invB = inv(full(A(:,xb)));
                    judge = find((xb>o&xb<=2*o)|xb>3*o+p);
                    sp(spnum).invB = invB(judge,:);
                    sp(spnum).w = c(xb) * invB;
                    lagnum = lagnum + 1;
                else
                    if i ~= spnum 
                        sp2 = sp(spnum).invB;
                        sp3 = sp(spnum).w;
                        sp(spnum).invB = sp(i).invB;
                        sp(spnum).w = sp(i).w;
                        sp(i).invB = sp2;
                        sp(i).w = sp3;
                    end
                end
                    lc = lc + plc * ldlv(ldi,2);
      end                      
end
   
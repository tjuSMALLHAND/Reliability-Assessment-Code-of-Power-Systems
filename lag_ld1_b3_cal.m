  function [lc,xbb,invBB1,num,lagnum,n,k]=lag_ld1_b3_cal(mpc,ldlv,A,b,c,xbb,invBB,delg)
       lagnum = 0;                            %��¼���˼����Ż���ֱ�����
       num =1;                                % num=1�����һ������ƥ��ʧ�ܣ����spnum+1��
       o=size(mpc.bus,1);
       p=size(mpc.gen,1);
       q=size(mpc.branch,1);
       ldlvnum=size(ldlv,1);
        b(delg+2*o) = 0;                         %�������������Ϊ0

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
                  BB = A(:,xb);                                                 %ͨ��xb������Ż�BB�������Ǵ�BC��ΪA�仯��
                  w = c(xb) / BB;                                               %------------��ʱ����----------------
              if isnan(w) == 0                                          % w ����NaNԪ��
                  if  invBB{i} * b >  -1e-15                
                          k = n - i + 1;                                      % k ��¼�ڼ����ҵ���ƥ������Ż�λ��xb
                          plc = w * b;
                          invBB1 = invBB{i};
                          lc = lc + plc * ldlv(ldi,2);
                          num = 0;                                       %num = 0��ʾ�ҵ����Ż�
                          xbb = xb;
                          break;                                        %�ҵ����˳�ѭ��
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
                invBB1 = invB(judge,:);
                lagnum = 1;
                n = n + 1;
          end
                spnum = 1;
                sp(spnum).invB = invBB1;
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


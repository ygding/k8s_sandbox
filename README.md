# The script create a K8s+Ceph environment
Some attention point:
- Disable `config.vbguest.auto_update = false` after all VirtualHost deployed, you may reboot 2
times to make new kernel effective eventhough,
- the kernel have to be upgraded > 3.10.0-1062.9.1.el7.x86_64, please run
 `yum -y upgrade` after install so that k8s(br_filter) can be brought up normally.
- After reboot VM and take new kernal active, the puppet will deploy K8s, after all done do following configuration changes:
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
- Now you can use `kubectl get nodes` to check K8s status
```
[root@puppet ~]# kubectl get nodes
NAME     STATUS     ROLES    AGE     VERSION
node1    Ready      <none>   49m     v1.15.0
node2    Ready      <none>   142m    v1.15.0
node3    NotReady   <none>   6m59s   v1.15.0
puppet   Ready      master   150m    v1.15.0
```
- Deploy Ceph on K8s (rook):
```
#kubectl create -f common.yaml
#kubectl create -f operator.yaml
#kubectl create -f cluster-test.yaml
#kubectl create -f toolbox.yaml
```
- Final result:
```
[root@puppet ~]# kubectl -n rook-ceph exec -it rook-ceph-tools-85cfdbbdd5-z4bl4 bash
[root@rook-ceph-tools-85cfdbbdd5-z4bl4 /]# ceph status
  cluster:
    id:     b83aa3fb-d7a9-49fe-bed0-ec994619aece
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum a (age 23m)
    mgr: a(active, since 22m)
    osd: 3 osds: 3 up (since 18m), 3 in (since 18m)

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   9.4 GiB used, 46 GiB / 55 GiB avail
    pgs:

[root@rook-ceph-tools-85cfdbbdd5-z4bl4 /]# ceph osd status
+----+-------+-------+-------+--------+---------+--------+---------+-----------+
| id |  host |  used | avail | wr ops | wr data | rd ops | rd data |   state   |
+----+-------+-------+-------+--------+---------+--------+---------+-----------+
| 0  | node1 | 3231M | 15.3G |    0   |     0   |    0   |     0   | exists,up |
| 1  | node2 | 3182M | 15.3G |    0   |     0   |    0   |     0   | exists,up |
| 2  | node3 | 3180M | 15.3G |    0   |     0   |    0   |     0   | exists,up |
+----+-------+-------+-------+--------+---------+--------+---------+-----------+
[root@rook-ceph-tools-85cfdbbdd5-z4bl4 /]# ceph df
RAW STORAGE:
    CLASS     SIZE       AVAIL      USED        RAW USED     %RAW USED
    hdd       55 GiB     46 GiB     9.4 GiB      9.4 GiB         16.91
    TOTAL     55 GiB     46 GiB     9.4 GiB      9.4 GiB         16.91

POOLS:
    POOL     ID     STORED     OBJECTS     USED     %USED     MAX AVAIL
[root@rook-ceph-tools-85cfdbbdd5-z4bl4 /]# rados df
POOL_NAME USED OBJECTS CLONES COPIES MISSING_ON_PRIMARY UNFOUND DEGRADED RD_OPS RD WR_OPS WR USED COMPR UNDER COMPR

total_objects    0
total_used       9.4 GiB
total_avail      46 GiB
total_space      55 GiB
```

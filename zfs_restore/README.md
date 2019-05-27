# zfs helyreállítás és/vagy adat mentés

    Inspirációt adó oldalak és források:
		https://github.com/eiselekd/dotfiles/blob/182635c6aa2af779dcf24be531baa4f8b81970e2/ubuntu/%23zfs_recover.org%23
		https://serverfault.com/questions/842955/restoring-data-after-zfs-destroy

    A zfs_revert-0.1.py amire majd szükséged lesz itt érhető el:  https://gist.github.com/jshoward/5685757

    HA töröltél filesystem|volume|snapshot és kell a visszaállítás; Akkor itt megtalálod miként tudsz egy előző pillanatra vissza állni!!!!!
    Ez egy valós visszaállítás története és valós nevekkel.
	A szám amit csináltam, betű(a) amit helyette lehet tenni


    0. 		Azonnal állítsd le a gépet!!
    0a. 	DE minimum exportáld a pool-t (zpool export SRV)
	    A Copy-On-Write technológia miatt így megmaradnak az adatok és az adminisztráció is.

    1. 		boot rescue módban ( Így nincsenek szolgáltatások és nem zavar be semmi )
    1a. 	Tedd másik gépbe
	    Még véletlen sem szabad, hogy mások használák.

    2. 		zpool import  import -o readonly=on -D -f SRV
	     "-D -f" nem kell feltétlen,

    3. 		zpool history SRV
	    itt látod a pool eseményeit; keresd meg, hogy kb. mikor volt amit elszúrtál

    4. 		zpool history -il SRV >history.txt
	    Mentsd el a history-t mert ebben keresed meg azt az időt amikor még jó volt!
	    "[txg:100313876]" ez a rész mondja meg, hogy az adminisztrációs állománynak milyen sorszáma volt

    5. 		zpool export SRV
	    Lecsatoljuk, mivel közvetlen fogjuk használni a keresés során

    6. 		fdisk -l /dev/sdg ; fdisk -l /dev/sdh
	    Itt a pool-t alkotó disk-ek vagy particiók mérete kell, a sector számra (7811919872)
	    Ha nagyobbat írsz be az nem okoz gondoot
		------------------------------
		Device          Start        End    Sectors  Size Type
		/dev/sdg1        2048 7811921919 7811919872  3,7T Solaris /usr & Apple ZFS
		/dev/sdg9  7814019072 7814037134      18063  8,8M Solaris reserved 1
		------------------------------

    7. 		zfs_revert-0.1.py -tb=7811919872 /dev/sdg1 és 
		zfs_revert-0.1.py -tb=7811919872 /dev/sdh1
	    Most keresed le a még elérhető adminisztrációs területeket és ezt is mentsd (revert.txt)
	    MINDEN diszken végezd el ami a pool része
		------------------------------
		TXG	TIME	TIMESTAMP	BLOCK ADDRESSES
		100379259	19 May 2019 21:33:29	1558294409	[472, 984]
		100379260	19 May 2019 21:33:36	1558294416	[480, 992]
		100379266	19 May 2019 21:34:19	1558294459	[272, 784]
		100379289	19 May 2019 21:38:54	1558294734	[456, 968, 7811919304, 7811919816]
		100379290	19 May 2019 21:39:00	1558294740	[464, 976, 7811919312, 7811919824]
		......
		100379291	19 May 2019 21:39:05	1558294745	[7811919320, 7811919832]
		100379298	19 May 2019 21:39:43	1558294783	[7811919120, 7811919632]
		100379299	19 May 2019 21:39:44	1558294784	[7811919128, 7811919640]
		What is the last TXG you wish to keep?
		------------------------------

    8. 		zpool import -o readonly=on -D -f -T <LAST-GOOD-TXG> poolName MINTA
		zpool import -o readonly=on  -f -T 100267909 SRV
	    "-D" csak ha sérült a pool jellemzően most nem kell
	    "LAST-GOOD-TXG" egy olyan számot válassz amit a zfs_revert-0.1.py írt ki és
	    a historyban a inkriinált esemény (törlés) elötti
	    !!!!!!!!!!!!!!SOKÁIG FOG FUTNI!!!!!!!!!!!!!!!!!!!
	    Mivel gyakorlatilag a pool ÖSSZES diszkét végig fogja olvasni!!!!
		Viszont a diszeket párhuzamossan olvassa

    9. 		Másold ki, zfs send, stb.....

	    NE HASZNÁLD ÍGY, mivel nem tudhatod, hogy mi íródott felül... 

	    Javaslat: "zfs send" -del kiszeded az(oka)t a "filesystem|volume|snapshot"-(oka)t máshova
		amelyekre szükséged van

    10. 	zpool export SRV ; zpool import SRV ; zpool history SRV
	    Ellenőrizük le, hogy visszaálltunk a tudottan valid adatokra a 
	    3,4 ponttal összehasonjítani





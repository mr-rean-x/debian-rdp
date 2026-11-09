# Debian RDP (Linux RDP in Docker)

Debian + XFCE desktop + xRDP — Docker er vitore full Linux desktop, RDP (port 3389) diye connect kora jay. Windows er Microsoft Remote Desktop / Windows App diye dhuka jabe.

Inspired by [hopingboyz/debianxrdp](https://github.com/hopingboyz/debianxrdp) — oi repo tar motoi, kintu password env var diye set kora jay, ar Railway deploy er jonno `railway.json` add kora ache.

## Vitore ki ache

- **OS:** Debian 12 (bookworm)
- **Desktop:** XFCE4
- **RDP:** xrdp, port **3389**
- **Browser:** Firefox ESR
- **Extra:** PulseAudio (RDP te sound)

## Login

- **Username:** `root`
- **Password:** `RDP_PASSWORD` env var ja diba (na dile default `changeme`)

> ⚠️ Default password diye RDP khula rakhba na — deploy er age `RDP_PASSWORD` e nijer strong password bosao.

## Railway te deploy (1 click er moto)

1. Railway dashboard e **New Project → Deploy from GitHub repo** → ei repo select koro.
2. Service er **Variables** e jao, add koro:
   - `RDP_PASSWORD` = tomar password (jemon `MrRean@2026`)
3. Deploy sesh hole **Settings → Networking → TCP Proxy** e jao, port **3389** diye TCP Proxy enable koro.
4. Railway je public address dibe (jemon `xxx.proxy.rlwy.net:12345`), oita diye connect koro:
   - **Windows:** Remote Desktop / Windows App → Computer: `xxx.proxy.rlwy.net:12345` → User: `root`, Password: tomar `RDP_PASSWORD`
   - **Android:** Microsoft Remote Desktop app, same vabe.

## VPS / PC te Docker diye

```bash
docker build -t debian-rdp .
docker run -d -p 3389:3389 -v rdp-home:/root -e RDP_PASSWORD=tomar-password --name debian-rdp debian-rdp
```

Ba `docker-compose` diye:

```bash
docker compose up -d
```

Tarpor RDP client diye `VPS-IP:3389` e connect koro, user `root`.

## Deploy 100% howar jonno ja kora hoise

Kono deploy er 100% guarantee keu dite pare na, kintu fail howar common karon gula sorano hoise:

- **Slim image:** `--no-install-recommends` diye build — image choto, build fast, fail er chance kom.
- **Wine main Dockerfile e nai:** Wine + i386 image 1GB+ boro kore ar build slow/fail er sobcheye boro karon chilo. Wine lagle `Dockerfile.wine` use koro: `docker build -f Dockerfile.wine -t debian-rdp .`
- **apt retry:** mirror hiccup hole `apt-get update` ekbar retry kore.
- **start.sh hardened:** dbus/pulseaudio fail korleo container morbe na; xrdp service script na cholle direct binary diye start hobe; log file na thakleo `tail -F` fail korbe na.
- **`.dockerignore`:** build context choto, Railway build fast hoy.

## Wine lagle?

Windows app chalate chaile `Dockerfile.wine` use koro (Railway te Dockerfile path change kore `Dockerfile.wine` select koro, ba VPS e `docker build -f Dockerfile.wine`).

## Sotyi kotha (limit)

- Railway **Trial plan e RAM ~0.5–1GB** — XFCE + Firefox cholbe, kintu heavy kaj / beshi tab khulle slow hobe.
- Trial er $5 credit / 30 din sesh hole RDP bondho hoye jabe — **24/7 er guarantee nai**.
- RDP port internet e khula thake, tai strong password must. `changeme` diye kokhono chalaiyo na.
- `/root` e ja save korba, container delete hole muche jabe — jodi Railway te Volume add koro (`/root` mount), tahole home folder bachbe.

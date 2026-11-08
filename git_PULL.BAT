
@echo off
setlocal
REM =====================================================================
REM DIRECTORY DEL PROGETTO:
REM c:\CASA\LINGUAGGI\ACCESS\PROGETTI_MDB\MSYS\MSys_DF00\
REM  git_PULL.BAT - scarica le modifiche da GitHub (origin/main)
REM  repository: https://github.com/icivixwalter/MSys_DF00
REM =====================================================================
set "REPO_URL=https://github.com/icivixwalter/MSys_DF00.git"
set "BRANCH=main"

REM si posiziona da solo nella cartella del repository (quella di questo bat)
cd /d "%~dp0"

where git >nul 2>&1 || (echo *** ERRORE: git non trovato nel PATH & pause & exit /b 1)
git rev-parse --is-inside-work-tree >nul 2>&1 || (echo *** ERRORE: %CD% non e' un repository git & pause & exit /b 1)

REM evita l'errore "dubious ownership" se la cartella appartiene a un altro utente
git config --global --get-all safe.directory | findstr /i /x /c:"%CD:\=/%" >nul 2>&1 || git config --global --add safe.directory "%CD:\=/%"

REM controlla/sistema il remote origin
git remote get-url origin >nul 2>&1 || git remote add origin "%REPO_URL%"
for /f "delims=" %%U in ('git remote get-url origin') do set "CUR_URL=%%U"
if /i not "%CUR_URL%"=="%REPO_URL%" (
    echo Remote origin era: %CUR_URL%
    echo Lo imposto a:      %REPO_URL%
    git remote set-url origin "%REPO_URL%"
)

echo REPOSITORY: %CD%
echo REMOTE    : %REPO_URL%  [branch %BRANCH%]
echo.

echo === FETCH: controllo le novita' su GitHub ===
git fetch origin
if errorlevel 1 (echo. & echo *** ERRORE FETCH: controllare connessione / credenziali GitHub *** & pause & exit /b 1)

REM collega il branch locale a origin/main (se non lo e' gia')
git branch --set-upstream-to=origin/%BRANCH% %BRANCH% >nul 2>&1

echo.
echo === STATO PRIMA DEL PULL ===
git status -sb
echo.

echo === PULL: scarico le modifiche da GitHub ===
git pull --no-edit --no-rebase origin %BRANCH%
if errorlevel 1 (
    echo.
    echo *** ERRORE PULL: leggere i messaggi sopra ***
    echo Se ci sono modifiche locali non salvate eseguire prima git_COMMIT.BAT
    echo oppure accantonarle con:  git stash   ^(poi git stash pop^)
    pause
    exit /b 1
)

echo.
echo === ULTIMI COMMIT ===
git log --oneline -5
echo.
echo === PULL COMPLETATO ===
pause
endlocal

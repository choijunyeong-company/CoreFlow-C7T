# Release

release 브랜치에 main을 병합하고, 새 버전 태그를 생성하여 GitHub Release를 수행합니다.

## 절차

1. `git checkout release`로 release 브랜치로 전환합니다.
2. `git merge main`으로 main 브랜치를 병합합니다.
3. `git tag --sort=-v:refname | head -1`로 최신 태그를 조회합니다.
4. 최신 태그의 patch 버전을 1 증가시킨 새 버전을 결정합니다. (예: `0.0.5` → `0.0.6`)
5. `git tag <새 버전>`으로 태그를 생성합니다.
6. `git push main release --tags`로 release 브랜치와 태그를 push합니다.
7. 이전 태그와 새 태그 사이의 커밋 로그를 `git log <이전태그>..<새태그> --oneline`으로 조회합니다.
8. 커밋 로그를 기반으로 변경사항을 정리하여 `gh release create`로 GitHub Release를 생성합니다.

## Release Notes 작성 형식

커밋 로그에서 Prefix별로 분류하여 작성합니다. 병합 커밋은 제외합니다.

```
## Changes

- **Feat** 설명
- **Refactor** 설명
- **Fix** 설명
- **Docs** 설명
```

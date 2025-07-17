# 🚀 Divary

<img width="512" alt="image" src="https://github.com/user-attachments/assets/cbf6da5b-a574-4bf0-83ac-be9f9d6e13a7" />


> Diver+Diary
스쿠버 다이버를 위한, 다이빙의 추억을 나만의 방식으로 기록하는 다이빙 로그 앱 🌊🐠

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-16.0-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

---

<br>

## 👥 멤버

| 박현규 | 조하은 | 김나영 |
|:------:|:------:|:------:|
| <img src="https://github.com/user-attachments/assets/cfc67f28-1e5d-4b83-80bb-9480038549bd" width="150" /> | <img src="https://github.com/user-attachments/assets/a71f49c8-1310-4b07-9693-1ca55df815f7" width="150" /> | <img src="https://github.com/user-attachments/assets/203bbc1b-c679-4581-ae14-be6046f5a8dc" width="150" /> |
| PL | FE | FE |
| [GitHub](https://github.com/ParkMazorika) | [GitHub](https://github.com/haeun030) | [GitHub](https://github.com/na0k1m) |



<br>


## 📱 소개

> ✍️ 다이빙 직후, 생생한 기억을 바로바로 쉽게 기록할 수 있게 도와줘요! <br>
🎨 사진과 스티커로 예쁘게 꾸며서 나만의 다이빙 로그를 특별하게 남길 수 있어요! <br>
🐠 해양 생물 도감에서 내가 본 바다 친구가 어떤 생물인지 찾아볼 수 있어요

<br>

## 📆 프로젝트 기간
- 전체 기간: `2025.07.03 - 2025.08.25`
- 개발 기간: `2025.07.05 - 2025.08.18`

<br>

## 🤔 요구사항
For building and running the application you need:

iOS 18.2 <br>
Xcode 16.2 <br>
Swift 6.0

<br>

## ⚒️ 개발 환경
* Front : SwiftUI
* 버전 및 이슈 관리 : Github, Github Issues
* 협업 툴 : Discord, Notion

<br>

## 🔎 기술 스택
### Envrionment
<div align="left">
<img src="https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white" />
<img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" />
<img src="https://img.shields.io/badge/SPM-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
</div>

### Development
<div align="left">
<img src="https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white" />
<img src="https://img.shields.io/badge/SwiftUI-42A5F5?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Alamofire-FF5722?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Moya-8A4182?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Kingfisher-0F92F3?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Combine-FF2D55?style=for-the-badge&logo=apple&logoColor=white" />
</div>

### Communication
<div align="left">
<img src="https://img.shields.io/badge/Notion-white.svg?style=for-the-badge&logo=Notion&logoColor=000000" />
<img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=Discord&logoColor=white" />
<img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white" />
</div>

<br>

## 📱 화면 구성
<table>
  <tr>
    <td>
      진행중
    </td>
    <td>
      진행중
    </td>
   
  </tr>
</table>

## 🔖 브랜치 컨벤션
* `main` - 제품 출시 브랜치
* `feat/#이슈` - 기능 단위로 독립적인 개발 환경을 위해 작성

<br>

## 🌀 코딩 컨벤션
* 카멜케이스 사용
클래스, 구조체, 열거형 이름: UpperCamelCase (PascalCase)
``` swift
struct LogBookPageView { ... }
enum DiveType { ... }
class ChallengeService { ... }
```

* 변수, 상수, 함수, 파라미터 이름: lowerCamelCase
``` swift
let diveLogId = UUID()
func fetchChallengeList(forUser userId: String) { ... }
```

## 📁 PR 컨벤션
* PR 템플릿
  - 📌 요약
  - ✅ 할 일

#### 🌟 태그 종류 (커밋 컨벤션과 동일)
| 태그        | 설명                                                   |
|-------------|--------------------------------------------------------|
| [Feat]      | 새로운 기능 추가                                       |
| [Fix]       | 버그 수정                                              |
| [Refactor]  | 코드 리팩토링 (기능 변경 없이 구조 개선)              |
| [Style]     | 코드 포맷팅, 들여쓰기 수정 등                         |
| [Docs]      | 문서 관련 수정                                         |
| [Test]      | 테스트 코드 추가 또는 수정                            |
| [Chore]     | 빌드/설정 관련 작업                                    |
| [Design]    | UI 디자인 수정                                         |
| [Hotfix]    | 운영 중 긴급 수정                                      |
| [CI/CD]     | 배포 및 워크플로우 관련 작업                          |

### ✅ PR 예시 모음
> 🎉 [Chore] 프로젝트 초기 세팅 <br>
> ✨ [Feat] 프로필 화면 UI 구현 <br>
> 🐛 [Fix] iOS 17에서 버튼 클릭 오류 수정 <br>
> 💄 [Design] 로그인 화면 레이아웃 조정 <br>
> 📝 [Docs] README에 프로젝트 소개 추가 <br>

<br>

## 📑 커밋 컨벤션

### 💬 깃모지 가이드

| 아이콘 | 코드 | 설명 | 원문 |
| :---: | :---: | :---: | :---: |
| 🐛 | bug | 버그 수정 | Fix a bug |
| ✨ | sparkles | 새 기능 | Introduce new features |
| 💄 | lipstick | UI/스타일 파일 추가/수정 | Add or update the UI and style files |
| ♻️ | recycle | 코드 리팩토링 | Refactor code |
| ➕ | heavy_plus_sign | 의존성 추가 | Add a dependency |
| 🔀 | twisted_rightwards_arrows | 브랜치 합병 | Merge branches |
| 💡 | bulb | 주석 추가/수정 | Add or update comments in source code |
| 🔥 | fire | 코드/파일 삭제 | Remove code or files |
| 🚑 | ambulance | 긴급 수정 | Critical hotfix |
| 🎉 | tada | 프로젝트 시작 | Begin a project |
| 🔒 | lock | 보안 이슈 수정 | Fix security issues |
| 🔖 | bookmark | 릴리즈/버전 태그 | Release / Version tags |
| 📝 | memo | 문서 추가/수정 | Add or update documentation |
| 🔧| wrench | 구성 파일 추가/삭제 | Add or update configuration files.|
| ⚡️ | zap | 성능 개선 | Improve performance |
| 🎨 | art | 코드 구조 개선 | Improve structure / format of the code |
| 📦 | package | 컴파일된 파일 추가/수정 | Add or update compiled files |
| 👽 | alien | 외부 API 변경 반영 | Update code due to external API changes |
| 🚚 | truck | 리소스 이동, 이름 변경 | Move or rename resources |
| 🙈 | see_no_evil | .gitignore 추가/수정 | Add or update a .gitignore file |

### 🏷️ 커밋 태그 가이드

 | 태그        | 설명                                                   |
|-------------|--------------------------------------------------------|
| [Feat]      | 새로운 기능 추가                                       |
| [Fix]       | 버그 수정                                              |
| [Refactor]  | 코드 리팩토링 (기능 변경 없이 구조 개선)              |
| [Style]     | 코드 포맷팅, 세미콜론 누락, 들여쓰기 수정 등          |
| [Docs]      | README, 문서 수정                                     |
| [Test]      | 테스트 코드 추가 및 수정                              |
| [Chore]     | 패키지 매니저 설정, 빌드 설정 등 기타 작업           |
| [Design]    | UI, CSS, 레이아웃 등 디자인 관련 수정                |
| [Hotfix]    | 운영 중 긴급 수정이 필요한 버그 대응                 |
| [CI/CD]     | 배포 관련 설정, 워크플로우 구성 등                    |

### ✅ 커밋 예시 모음
> 🎉 [Chore] 프로젝트 초기 세팅 <br>
> ✨ [Feat] 프로필 화면 UI 구현 <br>
> 🐛 [Fix] iOS 17에서 버튼 클릭 오류 수정 <br>
> 💄 [Design] 로그인 화면 레이아웃 조정 <br>
> 📝 [Docs] README에 프로젝트 소개 추가 <br>

<br>

## 🗂️ 폴더 컨벤션
```
//뷰마다 작업 섹션별, 파일 나누어서 작업
LogBook/
├── LogBookMain/
├── LogBookPage/
│   ├── Section/
│   ├── LogBookPageMock.swift
│   ├── LogBookPageModel.swift
│   └── LogBookPageView.swift
└──
```

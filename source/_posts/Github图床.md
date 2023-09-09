---
title: Github图床
date: 2023-09-07 20:28:08
tags: Python
---

# 0 前言

在前一篇[Gitee图床](https://lkzc19.github.io/2023/09/06/Gitee%E5%9B%BE%E5%BA%8A/)中成功的将图片上传到了Gitee并且拿到了图片的URL，并且在写"Gitee图床"时贴上图片的URL是可以正常访问的。但是在将文章往 Github Page 部署后却发现图片显示不了，可能是 Github 的限制。所以打算直接用 Github 作为图床。

# 1 正文

思路与上篇相同，只是请求略有不同，[官方文档](https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#create-or-update-file-contents)。

```markdown
PUT  https://api.github.com/repos/{owner}/{repo}/contents/{path}
```

`token` 参数位置从 body 换到了 请求头。且加一个 `'Content-Type': 'application/octet-stream'`。

Github token 获取

![Github token 获取](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-09-07-20-51-19.png)

Python 代码

```python
import argparse
import base64
import sys
from datetime import datetime
import os
import requests


if __name__ == '__main__':
    # 入参
    parser = argparse.ArgumentParser(description='gitee图床工具')
    parser.add_argument('img', help='图片地址')
    args = parser.parse_args()

    # 读取文件
    with open(args.img, 'rb') as it:
        file = it.read()

    # 判断是否是图片
    _, extension = os.path.splitext(args.img)
    image_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp']
    if extension.lower() not in image_extensions:
        print('[' + extension + ']文件非图片，不能上传')
        sys.exit(1)

    # 上传到gitee上的文件名 上传的频率不是很高, 使用秒即可
    filename = datetime.now().strftime("%Y-%m-%d-%H-%M-%S") + extension

    path_params = {
        'owner': 'lkzc19',
        'repo': 'blasphemy.zimg',
        'path': 'drinkice/' + filename
    }
    headers = {
        "Authorization": "Bearer {}".format(os.environ.get('GITHUB_BLASPHEMY')),
        'Content-Type': 'application/octet-stream'
    }
    body = {
        'content': base64.b64encode(file).decode('utf-8'), # 将图片文件转换为 Base64 编码
        'message': 'feat: 上传图片'
    }
    # https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#create-or-update-file-contents
    response = requests.put(
        'https://api.github.com/repos/{owner}/{repo}/contents/{path}'.format_map(path_params),
        headers=headers,
        json=body
    )
    if not response.ok:
        print('上传失败: ' + response.json()['message'])
        sys.exit(1)

    # 成功输出图片地址
    print('上传成功')
    gitee_img_url = response.json()['content']['download_url']
    print('markdown: \t' + ('![]({})'.format(gitee_img_url)))
    print('URL: \t\t' + gitee_img_url)
```

最后依然与上篇一样用 Shell 封住后，加入环境变量中即可。

# 3 对比

之前的效果：

![Gitee](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-09-07-20-58-40.png)

现在已经换为了Github做图床了。

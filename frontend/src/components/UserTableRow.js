import defaultPicture from "./../assets/profile.png";
import React from 'react';
import { Link } from "react-router-dom";
import { withTranslation } from "react-i18next";
import ProfileImage from "./ProfileImage";

const UserTableRow = (props) => {
    const { t, user, onRestore } = props; // Добавляем `onRestore` для восстановления пользователя
    const { username, name, surname, email, image, roles, status } = user;

    return (
        <tr key={username} className={status === 0 ? "text-muted" : ""}> {/* Серый текст для неактивных пользователей */}
            <td scope="row">
                <ProfileImage
                    width="32px"
                    height="32px"
                    imageSource={image ? image : defaultPicture}
                    username={username}
                />
            </td>
            <td>{username}</td>
            <td>{name}</td>
            <td>{surname}</td>
            <td>{email}</td>
            <td>{roles && roles.length > 0 ? roles.join(', ') : t('No Roles')}</td>
            <td>
                {status === 0 ? (
                    <button
                        className="btn btn-warning btn-sm"
                        onClick={() => onRestore(user.id)}
                    >
                        {t('Restore')}
                    </button>
                ) : (
                    <Link
                        to={'/user/' + username}
                        className="btn btn-success btn-sm"
                    >
                        {t('Open')}
                    </Link>
                )}
            </td>
        </tr>
    );
};

export default withTranslation()(UserTableRow);